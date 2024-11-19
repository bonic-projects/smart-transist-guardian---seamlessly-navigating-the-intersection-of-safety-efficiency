// Libraries for MPU6050, GPS, Wi-Fi, and Firebase
#include <Adafruit_MPU6050.h>
#include <TinyGPS++.h>
#include <HardwareSerial.h>
#include <Wire.h>
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// Wi-Fi credentials
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"

// Firebase credentials
#define API_KEY "AIzaSyBpcZubY4c61E_BHuQlgVhOeqdTYIigDvM"
#define DATABASE_URL "https://smart-transist-guardian-default-rtdb.firebaseio.com/"
#define USER_EMAIL "device@gmail.com"
#define USER_PASSWORD "12345678"

// Firebase objects and configuration
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseData stream;
String uid;
String path;

// Sensor and GPS configuration
Adafruit_MPU6050 mpu;
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);  // Use UART2 for GPS on pins 16 (RX2) and 17 (TX2)

// Declare latitude and longitude globally to use in the functions
float latitude = 0.0;
float longitude = 0.0;

bool isSent = false;
bool accident = true;
unsigned long flipStartTime = 0;
const unsigned long flipDurationThreshold = 3000; // 3 seconds
const float flipAccThreshold = 5.0;  // Threshold for detecting flip
const float suddenAccThreshold = 45.0; // Threshold for detecting sudden acceleration
const float suddenDeaccThreshold = 2.0; // Threshold for detecting sudden deacceleration
unsigned long sendDataPrevMillis = 0;
unsigned long lastAlertTime = 0;
const unsigned long alertCooldown = 5000;  // 5 seconds

// Setup function to initialize Wi-Fi, Firebase, MPU6050, and GPS
void setup() {
  Serial.begin(115200);
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17);

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) delay(10);
  }
  Serial.println("MPU6050 Found!");
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

  // Configure Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;
  fbdo.setResponseSize(2048);
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Firebase.setDoubleDigits(5);
  config.timeout.serverResponse = 10 * 1000;

  // Get Firebase User UID
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.'); 
    delay(1000);
  }
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

  path = "/devices/" + uid + "/reading/accident";
}

// Main loop function
void loop() {
  detectAccident();  // Accident detection logic
  detectSuddenAcceleration();  // Sudden acceleration detection
  detectSuddenDeacceleration();  // Sudden deacceleration detection
}

// Function to detect accident based on MPU6050 data
void detectAccident() {
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);
  float z_acceleration = accel.acceleration.z;

  Serial.print("Z-Acceleration: ");
  Serial.println(z_acceleration);

  // Accident detection logic
  if (z_acceleration < flipAccThreshold) {
    if (!isSent) {
      if (flipStartTime == 0) {
        flipStartTime = millis();
        Serial.println("Flip condition detected - starting timer...");
      } else if (millis() - flipStartTime >= flipDurationThreshold) {
        sendAlert(); 
        isSent = true;
        Serial.println("Accident detected! Alert sent to Firebase.");
      }
    }
  } else {
    flipStartTime = 0;
    if (isSent) {
      Serial.println("Vehicle returned to stable position - alert reset.");
    }
    isSent = false;
  }

  // Read GPS data
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }

  // Update the global latitude and longitude values when GPS data is available
  if (gps.location.isUpdated()) {
    latitude = gps.location.lat();
    longitude = gps.location.lng();
  }
  delay(100);
}

// Function to detect sudden acceleration
void detectSuddenAcceleration() {
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);
  float total_acceleration = sqrt(pow(accel.acceleration.x, 2) + pow(accel.acceleration.y, 2) + pow(accel.acceleration.z, 2));

  Serial.print("Total Acceleration: ");
  Serial.println(total_acceleration);

  if (total_acceleration > suddenAccThreshold) {
    Serial.println("Sudden acceleration detected!");
    sendAlert();
  }
}

// Function to detect sudden deacceleration
void detectSuddenDeacceleration() {
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);
  float total_acceleration = sqrt(pow(accel.acceleration.x, 2) + pow(accel.acceleration.y, 2) + pow(accel.acceleration.z, 2));

  Serial.print("Total Acceleration: ");
  Serial.println(total_acceleration);

  if (total_acceleration < suddenDeaccThreshold) {
    Serial.println("Sudden deacceleration detected!");
    sendAlert();
  }
}

// Function to send alert with GPS data to Firebase
void sendAlert() {
    if (millis() - lastAlertTime >= alertCooldown) {
        updateData();  // Send GPS data
        Serial.println("Alert sent to Firebase");
        lastAlertTime = millis();
    } else {
        Serial.println("Alert skipped to avoid rapid repeats");
    }
}

// Function to update data on Firebase periodically without GPS data
void updateData() {
    FirebaseJson json;
    json.set("Accident", accident);
    json.set("latitude", latitude);
    json.set("longitude", longitude);
    json.set(F("ts/.sv"), F("timestamp"));  // Only set timestamp for periodic updates
    Serial.printf("Updating data with timestamp... %s\n", Firebase.setJSON(fbdo, path.c_str(), json) ? fbdo.to<FirebaseJson>().raw() : fbdo.errorReason().c_str());
    Serial.println("Data update sent to Firebase.");
} 

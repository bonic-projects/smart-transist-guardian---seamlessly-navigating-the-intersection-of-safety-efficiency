#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include <Adafruit_MPU6050.h>
#include <Wire.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseData stream;

String uid;
String path;

// MPU6050 object
Adafruit_MPU6050 mpu;

// GPS module pins (adjust if necessary)
static const int RXPin = 4, TXPin = 3;  // RX, TX for GPS
static const uint32_t GPSBaud = 9600;   // GPS module baud rate

// GPS object
TinyGPSPlus gps;
SoftwareSerial ss(RXPin, TXPin);

String lati = "";
String longi = "";

// Variables to store previous acceleration for deceleration and acceleration detection
float prevAccelX = 0.0, prevAccelY = 0.0, prevAccelZ = 0.0;

void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  ss.begin(GPSBaud);

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) delay(10);
  }
  Serial.println("MPU6050 Found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);

   WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  unsigned long ms = millis();
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();


  //FIREBASE
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Limit the size of response payload to be collected in FirebaseData
  fbdo.setResponseSize(2048);

  Firebase.begin(&config, &auth);

  // Comment or pass false value when WiFi reconnection will control by your code or third party library
  Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);

  config.timeout.serverResponse = 10 * 1000;

  // Getting the user UID might take a few seconds
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

  path = "devices/" + uid + "/reading";
}

void updateData(){
  if (Firebase.ready() && (millis() - sendDataPrevMillis > 4000 || sendDataPrevMillis == 0))
  {
    sendDataPrevMillis = millis();
    FirebaseJson json;
    json.set("lati", lati);
    json.set("longi", longi);
    json.set(F("ts/.sv"), F("timestamp"));
    // Serial.printf("Set json... %s\n", Firebase.RTDB.set(&fbdo, path.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    Serial.printf("Set data with timestamp... %s\n", Firebase.setJSON(fbdo, path.c_str(), json) ? fbdo.to<FirebaseJson>().raw() : fbdo.errorReason().c_str());
    Serial.println(""); 
  }
}

void loop() {
readData();
}

void readData(){
    // Get accelerometer and gyroscope data
  sensors_event_t accel, gyro;
  mpu.getEvent(&accel, &gyro);

  // Print acceleration data
  Serial.print("Acceleration (X,Y,Z): ");
  Serial.print(accel.acceleration.x);
  Serial.print(", ");
  Serial.print(accel.acceleration.y);
  Serial.print(", ");
  Serial.print(accel.acceleration.z);
  Serial.println(" m/s^2");

  // Print gyroscope data
  Serial.print("Rotation (X,Y,Z): ");
  Serial.print(gyro.gyro.x);
  Serial.print(", ");
  Serial.print(gyro.gyro.y);
  Serial.print(", ");
  Serial.print(gyro.gyro.z);
  Serial.println(" rad/s");

  // Accident detection based on sudden deceleration
  float decelThreshold = 15.0;  // Deceleration threshold for accident detection
  if (detectSuddenDeceleration(accel.acceleration.x, accel.acceleration.y, accel.acceleration.z, decelThreshold)) {
    Serial.println("Potential accident detected due to sudden deceleration!");
    getGPSLocation();
  }

  // Accident detection based on sudden acceleration
  float accelThreshold = 10.0;  // Acceleration threshold for accident detection
  if (detectSuddenAcceleration(accel.acceleration.x, accel.acceleration.y, accel.acceleration.z, accelThreshold)) {
    Serial.println("Potential accident detected due to sudden acceleration!");
    getGPSLocation();
  }

  // Accident detection based on vehicle flipping
  if (detectVehicleFlip(gyro.gyro.x, gyro.gyro.y, gyro.gyro.z)) {
    Serial.println("Potential accident detected due to vehicle flipping!");
    getGPSLocation();
  }

  // Read GPS data
  while (ss.available() > 0) {
    gps.encode(ss.read());
    if (gps.location.isUpdated()) {
      Serial.print("Location: ");
      Serial.print(gps.location.lat(), 6);
      Serial.print(", ");
      Serial.println(gps.location.lng(), 6);
    }
  }

  // Update previous acceleration values for the next loop
  prevAccelX = accel.acceleration.x;
  prevAccelY = accel.acceleration.y;
  prevAccelZ = accel.acceleration.z;

  // Delay for stability
  delay(1000);
}

// Function to log GPS location during accident detection
void getGPSLocation() {
  if (gps.location.isValid()) {
    Serial.print("Accident detected at Location (Lat, Lon): ");
    Serial.print(gps.location.lat(), 6);
    Serial.print(", ");
    Serial.println(gps.location.lng(), 6);
  } else {
    Serial.println("GPS location not valid.");
  }
}

// Function to detect sudden deceleration
bool detectSuddenDeceleration(float accelX, float accelY, float accelZ, float threshold) {
  // Calculate change in acceleration for each axis
  float deltaX = prevAccelX - accelX;
  float deltaY = prevAccelY - accelY;
  float deltaZ = prevAccelZ - accelZ;

  // Check if deceleration exceeds the threshold on any axis
  if (deltaX > threshold || deltaY > threshold || deltaZ > threshold) {
    return true;
  }
  return false;
}

// Function to detect sudden acceleration
bool detectSuddenAcceleration(float accelX, float accelY, float accelZ, float threshold) {
  // Calculate change in acceleration for each axis
  float deltaX = accelX - prevAccelX;
  float deltaY = accelY - prevAccelY;
  float deltaZ = accelZ - prevAccelZ;

  // Check if acceleration exceeds the threshold on any axis
  if (deltaX > threshold || deltaY > threshold || deltaZ > threshold) {
    return true;
  }
  return false;
}

// Function to detect vehicle flip based on gyroscope data
bool detectVehicleFlip(float gyroX, float gyroY, float gyroZ) {
  // Assuming the gyroscope is aligned to detect tilt changes,
  // we use the X and Y axis for pitch and roll detection
  float tiltThreshold = 1.57;  // Approximately 90 degrees in radians
  if (abs(gyroX) > tiltThreshold || abs(gyroY) > tiltThreshold) {
    return true;  // Vehicle flipped upside down
  }
  return false;
}

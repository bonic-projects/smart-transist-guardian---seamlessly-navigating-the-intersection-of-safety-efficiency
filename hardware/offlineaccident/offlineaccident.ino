#include <Adafruit_MPU6050.h>
#include <TinyGPS++.h>
#include <HardwareSerial.h>
#include <Wire.h>

Adafruit_MPU6050 mpu;
TinyGPSPlus gps;             // Create GPS object
HardwareSerial gpsSerial(2);  // Use UART2 for GPS on pins 16 (RX2) and 17 (TX2)

bool isSent = false;
unsigned long flipStartTime = 0;
const unsigned long flipDurationThreshold = 3000; // 3 seconds
const float flipAccThreshold = 5.0;  // Threshold for detecting flip 

void setup() {
  Serial.begin(115200);       
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17); // Initialize GPS
  delay(1000);
  Serial.println("Testing NEO-7M GPS Module...");

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) delay(10);
  }
  Serial.println("MPU6050 Found!");
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);
}

void loop() {
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
        sendAlert();   // Send GPS location upon accident detection
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

  // if (gps.location.isUpdated()) {        
  //   Serial.print("Latitude: ");
  //   Serial.println(gps.location.lat(), 6);
  //   Serial.print("Longitude: ");
  //   Serial.println(gps.location.lng(), 6);
  //   Serial.print("Altitude: ");
  //   Serial.println(gps.altitude.meters());
  //   Serial.print("Satellites: ");
  //   Serial.println(gps.satellites.value());
  //   Serial.print("Speed: ");
  //   Serial.println(gps.speed.kmph());
  //   Serial.println("---------------------");
  // }

  delay(1000);  // Delay for readability
}

void sendAlert() {
  // Send GPS data to Firebase or Serial print as placeholder
  if (gps.location.isValid()) {
    Serial.print("Sending GPS Location - Latitude: ");
    Serial.print(gps.location.lat(), 6);
    Serial.print(", Longitude: ");
    Serial.println(gps.location.lng(), 6);
  } else {
    Serial.println("No valid GPS data available for sending.");
  }
}

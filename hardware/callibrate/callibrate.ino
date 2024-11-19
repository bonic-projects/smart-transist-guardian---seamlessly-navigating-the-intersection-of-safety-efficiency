#include <Adafruit_MPU6050.h>
#include <Wire.h>
#include <Arduino.h>

Adafruit_MPU6050 mpu;

unsigned long startTime = 0;
const unsigned long calibrationTime = 60000; // Calibration time in milliseconds (1 minute)
float maxAcc = 0.0;  // Variable to store the highest acceleration value
float maxDec = 0.0;  // Variable to store the lowest acceleration (deceleration) value

void setup() {
  Serial.begin(115200);
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) delay(10);
  }
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);

  startTime = millis();
  Serial.println("Calibration started. Collecting data for 1 minute...");
}

void loop() {
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);

  float total_acceleration = sqrt(pow(accel.acceleration.x, 2) + pow(accel.acceleration.y, 2) + pow(accel.acceleration.z, 2));

  // During the calibration phase (1 minute)
  if (millis() - startTime <= calibrationTime) {
    // Update maxAcc for the highest acceleration value observed
    if (total_acceleration > maxAcc) {
      maxAcc = total_acceleration;
    }
    // Update maxDec for the lowest (negative) acceleration value observed
    if (total_acceleration < maxDec || maxDec == 0.0) {
      maxDec = total_acceleration;
    }

    Serial.print("CALIBRATION: ");
    Serial.println(total_acceleration);
  } else {
    // After calibration, print the maximum acceleration and deceleration values
    if (millis() - startTime <= calibrationTime + 1000) { // Print once after calibration is complete
      Serial.println("Calibration complete.");
      Serial.print("Maximum Acceleration (maxAcc): ");
      Serial.println(maxAcc);
      Serial.print("Maximum Deceleration (maxDec): ");
      Serial.println(maxDec);
    }

    // Normal operation
    Serial.print("NORMAL: ");
    Serial.println(total_acceleration);
  }

  delay(100);
}

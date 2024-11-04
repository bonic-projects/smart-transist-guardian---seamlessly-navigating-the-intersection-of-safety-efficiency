#include <TinyGPS++.h>
#include <HardwareSerial.h>

TinyGPSPlus gps;          // Create GPS object
HardwareSerial gpsSerial(2); // Use UART2 for GPS

void setup() {
  Serial.begin(115200);        // Start Serial Monitor at 115200 baud
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17); // Start GPS module at 9600 baud on pins 16 (RX2) and 17 (TX2)
  delay(1000);
  Serial.println("Testing NEO-7M GPS Module...");
}

void loop() {
  while (gpsSerial.available() > 0) {    // Check if data is available from GPS
    gps.encode(gpsSerial.read());        // Parse GPS data
  }

  if (gps.location.isUpdated()) {        // Check if GPS location data is available
    // Serial.print("Latitude: ");
    Serial.println(gps.location.lat(), 6);
    // Serial.print("Longitude: ");
    Serial.println(gps.location.lng(), 6);
    Serial.print("Altitude: ");
    Serial.println(gps.altitude.meters());
    Serial.print("Satellites: ");
    Serial.println(gps.satellites.value());
    Serial.print("Speed: ");
    Serial.println(gps.speed.kmph());
    Serial.println("---------------------");
  }
}
// #include <HardwareSerial.h>

// HardwareSerial gpsSerial(2); // Use UART2 for GPS

// void setup() {
//   Serial.begin(115200);
//   gpsSerial.begin(9600, SERIAL_8N1, 16, 17); // Change to 4800 if needed
//   Serial.println("Testing GPS raw data...");
// }

// void loop() {
//   while (gpsSerial.available() > 0) {
//     Serial.write(gpsSerial.read()); // Pass data from GPS to Serial Monitor
//   }
// }

#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
#define API_KEY "AIzaSyBpcZubY4c61E_BHuQlgVhOeqdTYIigDvM"
#define DATABASE_URL "https://smart-transist-guardian-default-rtdb.firebaseio.com/"
#define USER_EMAIL "device@gmail.com"
#define USER_PASSWORD "12345678"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseData stream;

String uid;
String path;

const int sensorPin = 18;  
int sensorValue = 0;
String status = ""; 
unsigned long sendDataPrevMillis = 0;

void setup() {
  Serial.begin(115200);
  pinMode(sensorPin, INPUT);

  // Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Firebase
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
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

  // Getting the user UID
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);
  path = "devices/" + uid + "/reading/gate-1";
}

void updateData(){
  if (Firebase.ready() && (millis() - sendDataPrevMillis > 2000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    FirebaseJson json;
    json.set("status", status);
    json.set(F("ts/.sv"), F("timestamp"));
    Serial.printf("Set data with timestamp... %s\n", Firebase.setJSON(fbdo, path.c_str(), json) ? fbdo.to<FirebaseJson>().raw() : fbdo.errorReason().c_str());
    Serial.println(""); 
  }
}

void readStatus(){
  sensorValue = digitalRead(sensorPin);  // Corrected line
  if (sensorValue == LOW) {
    Serial.println("Railway gate close.");
    status = "close";
  } else {
    Serial.println("Railway gate open.");
    status = "open";
  }
  delay(1000);
}

void loop() {
  readStatus();
  updateData();
}

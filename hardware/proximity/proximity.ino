const int sensorPin = 18;  
int sensorValue = 0; 

void setup() {
  Serial.begin(115200);
  pinMode(sensorPin, INPUT);
}

void loop() {
  sensorValue = digitalRead(sensorPin)
  if (sensorValue == HIGH) {
    Serial.println("Railway gate closed.");
  } else {
    Serial.println("Railway gate open.");
  }
  delay(1000);
}

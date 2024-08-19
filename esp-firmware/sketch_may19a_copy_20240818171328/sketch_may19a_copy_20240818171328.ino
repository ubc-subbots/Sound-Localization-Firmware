#include <SPI.h>
#define readypin 9
const int chipSelectPin = 10; // Define the chip select pin
#define finishpin 8 
//miso is d12
//mosi is d11
//sck is d13/



void setup() {
   // Initialize SPI communication
  SPI.begin();

  // Set the chip select pin as an output
  pinMode(chipSelectPin, OUTPUT);
  pinMode(readypin,INPUT);
  // Initialize Serial communication
  Serial.begin(9600);
}

void loop() {

  while(digitalRead(readypin) == LOW){
    delay(50);
    Serial.println("waiting for ready pin");
    digitalWrite(finishpin, LOW);
    digitalWrite(chipSelectPin, HIGH);

  }




  digitalWrite(finishpin, LOW);

  delay(50);
  // Enable the SPI communication
  digitalWrite(chipSelectPin, LOW);

  Serial.println("CS is now low");

short kek;
  // Send data to SPI device
kek=SPI.transfer16(0x5555); // Example data, you can change this

Serial.println("spi transfer passed");
  // Disable SPI communication
    digitalWrite(chipSelectPin, HIGH);
Serial.println("chip select high");

    Serial.println(kek,BIN);

    digitalWrite(finishpin, HIGH);

Serial.println("finish pin high");
  // Wait for a moment
  delay(50);

  // Read data from SPI device (if needed)
  // byte receivedData = SPI.transfer(0x00); // Example read operation

  // Print received data (if needed)
  // Serial.println(receivedData);
}
/*
 * 
 * File:        basic_ble_peripheral_for_mask
 * Description: Implements a basic BLE peripheral for device testing
 * Author:      Seth Hunter
 * Date:        DEC 1 2021
 * 
 */

//USE R-B-G byte order for the Dot matrix arrays

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define PERIPHERAL_NAME             "Eyelid Display"

// use uuidgen on commandline to generate unique IDs 
#define SERVICE_UUID                "384B14B0-A048-4C76-B0A3-5430592032DA"
#define CHARACTERISTIC_INPUT_UUID   "627F7CE9-97FD-4381-9BDC-AB8C08EF0044"
#define CHARACTERISTIC_OUTPUT_UUID  "33C57932-ED8D-4050-8165-BBE019ABA141"

#define clockPin 22     // GPIO-PIN
#define dataPin 21    // GPIO-PIN
#define NUM_LEDS 128  // Number of APA102 LEDs in String

typedef struct colorRGBB  {
    uint8_t red, green, blue, brightness;
} colorRGBB;

// Output characteristic is used to send the response back to the connected phone
BLECharacteristic *pOutputChar;
bool updateLEDs = false; 
const int dataLength = 386;  //number of channels, 3 * LEDs + 1 for endchar of 0 added by ios? + 1 for brightness value
int ledValues[dataLength];
static uint8_t outputData[1];

// Class defines methods called when a device connects and disconnects from the service
class ServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        Serial.println("BLE Client Connected");
    }
    void onDisconnect(BLEServer* pServer) {
        BLEDevice::startAdvertising();
        Serial.println("BLE Client Disconnected");
    }
};

class InputReceivedCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharWriteState) {
        //uint8_t *inputValues = pCharWriteState->getData(); //appears to only store 32 bits
        std::string inputValues = pCharWriteState->getValue();

        if(inputValues.length() == dataLength) {
          Serial.println("All Values Recieved:");
          Serial.println(dataLength); 
          //Serial.println(inputValues.c_str());
          outputData[0] = 1; 

          String inputStr = String(inputValues.c_str()); 
          //Serial.print("String size: ");
          //Serial.println(inputStr.length()); 

          char charBuf[dataLength]; 
          inputStr.toCharArray(charBuf, dataLength); 

          for(int i=0; i<dataLength; i++) {
            ledValues[i] = int(charBuf[i])-1;  //to account for clamping of blacks on iOS side, cannot send 0s, ioS only sends a 1...255 
            //Serial.print(charBuf[i], HEX);
            //Serial.print(ledValues[i]);  
            //Serial.print(",");
          }
          updateLEDs = true; 

        } else {
          Serial.print("Only Recieved:");
          Serial.print(sizeof(inputValues)); 
          Serial.print(inputValues.length()); 
          outputData[0] = 0;
        }

        //here we can recieve R G B values and a brightness value 0-31 
        
        Serial.printf("\nSending response:   %02x\r\n", outputData[0]);  
        pOutputChar->setValue((uint8_t *)outputData, 1);
        pOutputChar->notify();
    }
};

void writeByte(uint8_t b) {
  uint8_t pos;
  for (pos=0;pos<=7;pos++) {
     digitalWrite(dataPin, b >> (7-pos) & 1);
     digitalWrite(clockPin, HIGH);
     digitalWrite(clockPin, LOW);
   }
}

void startFrame() {
  //Serial.println("startFrame");
  writeByte(0);
  writeByte(0);
  writeByte(0);
  writeByte(0);
}

void endFrame(uint16_t count) {
  //Serial.println("endFrame");
  writeByte(0xFF);
  writeByte(0xFF);
  writeByte(0xFF);
  writeByte(0xFF);
}

void writeRGB(uint8_t red, uint8_t green, uint8_t blue, uint8_t brightness) {
  writeByte(0b11100000 | brightness);
  //Serial.print(brightness);
  //Serial.print(",");
  writeByte(blue);
  //Serial.print(red);
  //Serial.print(",");
  writeByte(green);
  //Serial.print(blue);
  //Serial.print(",");
  writeByte(red);
  //Serial.print(green);
  //Serial.print(",");
}

void writeColor(colorRGBB color) {
  writeRGB(color.red, color.green, color.blue, color.brightness);
}

void writeColors(colorRGBB * colors, uint16_t count) {
  //Serial.println("writeColors");
  startFrame();
  for(uint16_t i = 0; i < count; i++) {
    writeColor(colors[i]);
  }
  endFrame(count);
} 

void outputFrame(uint16_t b=31) {
  colorRGBB RGB[NUM_LEDS]; 
   int subPixel = 0; 
   b= ledValues[subPixel];  //the first byte = brightness for all from slider. 
  for(int i=0; i<NUM_LEDS; i++) {
       subPixel++;
       RGB[i].red=ledValues[subPixel];
       subPixel++;
       RGB[i].green=ledValues[subPixel];
       subPixel++; 
       RGB[i].blue=ledValues[subPixel];
       RGB[i].brightness=b;
  }
  writeColors(RGB, NUM_LEDS);
}


void setup() {
  // Use the Arduino serial monitor set to this baud rate to view BLE peripheral logs 
  Serial.begin(115200);
  Serial.println("Begin Setup BLE Service and Characteristics");

  //APA102 communication pins 
  digitalWrite(dataPin, LOW);
  pinMode(dataPin, OUTPUT);
  digitalWrite(clockPin, LOW);
  pinMode(clockPin, OUTPUT);

  // Configure the server
  BLEDevice::init(PERIPHERAL_NAME);
  BLEServer *pServer = BLEDevice::createServer();

  // Create the service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a characteristic for the service
  BLECharacteristic *pInputChar = pService->createCharacteristic(
                              CHARACTERISTIC_INPUT_UUID,                                        
                              BLECharacteristic::PROPERTY_WRITE_NR | BLECharacteristic::PROPERTY_WRITE);


  pOutputChar = pService->createCharacteristic(
                              CHARACTERISTIC_OUTPUT_UUID,
                              BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
                                 

  // Hook callback to report server events
  pServer->setCallbacks(new ServerCallbacks());
  pInputChar->setCallbacks(new InputReceivedCallbacks());

  // Initial characteristic value
  outputData[0] = 0x00;
  pOutputChar->setValue((uint8_t *)outputData, 1);

  // Start the service
  pService->start();

  // Advertise the service
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);   //can play with this to recieve shorter or longer buffers 
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("BLE Service is advertising");
}

void loop() {
  // put your main code here, to run repeatedly:
  if(updateLEDs) {
      outputFrame(3);  //brightness 
      updateLEDs = false; 
  }
  delay(16.6);  //60hz starting out? 
}
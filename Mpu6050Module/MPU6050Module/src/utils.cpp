#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <MPU9250_WE.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include "utils.h"


void blink(const uint8_t &ledPin, const uint8_t &n)
{
    for(uint8_t i=0; i<n; i++)
    {
        digitalWrite(ledPin, HIGH);
        delay(100);
        digitalWrite(ledPin, LOW);
        delay(50);
    }
}


void printGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps)
{
    while(GpsSerial.available() > 0)
    {
        gps.encode(GpsSerial.read());
        // Serial.print(char(GpsSerial.read()));
    }
    
    if(gps.location.isUpdated())
    {
        Serial.print("LAT: ");
        Serial.println(gps.location.lat(), 6);
        Serial.print("LONG: "); 
        Serial.println(gps.location.lng(), 6);
        Serial.print("SPEED (km/h) = "); 
        Serial.println(gps.speed.kmph()); 
        Serial.print("ALT (min)= "); 
        Serial.println(gps.altitude.meters());
        Serial.print("HDOP = "); 
        Serial.println(gps.hdop.value() / 100.0); 
        Serial.print("Satellites = "); 
        Serial.println(gps.satellites.value()); 
        Serial.print("Time in UTC: ");
        Serial.println(String(gps.date.year()) + "/" + String(gps.date.month()) + "/" + String(gps.date.day()) + "," + String(gps.time.hour()) + ":" + String(gps.time.minute()) + ":" + String(gps.time.second()));
        Serial.println("");
    }

}

void printMpu(MPU9250_WE &mpu, xyzFloat &corrGyrRaw, xyzFloat &gValue)
{
    corrGyrRaw = mpu.getCorrectedGyrRawValues();
    gValue = mpu.getGValues();
  
    Serial.println("m/s values (x,y,z):");
    Serial.print(gValue.x * 9.806);
    Serial.print("   ");
    Serial.print(gValue.y * 9.806);
    Serial.print("   ");
    Serial.println(gValue.z * 9.806);
 
    Serial.println("Gyroscope raw values with offset:");
    Serial.print(corrGyrRaw.x);
    Serial.print("   ");
    Serial.print(corrGyrRaw.y);
    Serial.print("   ");
    Serial.println(corrGyrRaw.z);

}

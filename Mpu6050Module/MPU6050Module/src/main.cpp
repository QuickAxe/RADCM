#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <MPU9250_WE.h>

#include "utils.h"

#define IMU_ADDRESS 0x68    //Change to the address of the IMU

#define i2cSDA 4
#define i2cSCL 5

#define RX 14
#define TX 12

//! configure this later
#define ledPin 3

#define GPS_BAUD 9600

MPU9250_WE mpu = MPU9250_WE(IMU_ADDRESS);

// stuff for storing the mpu values
xyzFloat corrGyrRaw;
xyzFloat gValue;

// init the gps object and set its uart pins 
TinyGPSPlus gps;
SoftwareSerial GpsSerial( RX, TX);


// ============================================================================ Setup ==================================================================================
void setup() 
{
    Wire.begin(i2cSDA, i2cSCL);
    Serial.begin(9600);

    GpsSerial.begin(GPS_BAUD);

    pinMode(ledPin, OUTPUT);

    delay(500);
    Serial.println("Serial communication Begun:");

    if(mpu.init())
        Serial.println("MPU initialised");
    else 
    {
        Serial.println("Error initialising MPU");
        // while(true)
        {
            blink(ledPin, 6);
            delay(500);
        }
    }


    Serial.println("Calibrating MPU, keep it level and DONT MOVE IT");
    delay(1000);
    mpu.autoOffsets();
    Serial.println("Done!");

// ================================== Digital Filter stuff ====================================
    mpu.enableGyrDLPF();

    mpu.setGyrDLPF(MPU9250_DLPF_6);  // lowest noise

    mpu.setGyrRange(MPU9250_GYRO_RANGE_500);

    mpu.setAccRange(MPU9250_ACC_RANGE_4G);

    mpu.enableAccDLPF(true);

    mpu.setAccDLPF(MPU9250_DLPF_6);  // lowest noise

}


// ================================================================================== MAIN LOOP ============================================================================

unsigned long start = 0;
void loop() 
{
    if( (millis() - start) >= 1000)
    {   
        start=millis();
        Serial.println(".........................................................heartbeat...............................................................");
    }

    printGPS(GpsSerial, gps);
    printMpu(mpu, corrGyrRaw, gValue);
}

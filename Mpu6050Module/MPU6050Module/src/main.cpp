#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <MPU9250_WE.h>
#include <vector>

#include "utils.h"

// ==================================================================== Params ========================================================================

#define IMU_ADDRESS 0x68    //Change to the address of the IMU

// I2C pins for the mpu6500 Module
#define i2cSDA 4
#define i2cSCL 5

// UART pins for the gps module 
#define RX 14
#define TX 12

//! configure this later
// Status LED pin
#define ledPin 3

#define GPS_BAUD 9600

// the interval in ms between consequitive mpu sensor polls
// set to 20ms for a 50hz polling rate for now
#define POLL_INTERVAL 20

// the threshold for the Z-Diff anomaly detection function
// value stolen from the frontie's code, 
// using own value because the frontie's one seems rather absurd (delta 18 m/s^2)
#define THRESHOLD 6

// The number of ms to wait after detecting an anomaly, 
// before being able to send another 
#define ANOMALY_DETECTION_COOLDOWN 5000

// ----------------------------------------------------------------- Declarations ----------------------------------------------------------------------

MPU9250_WE mpu = MPU9250_WE(IMU_ADDRESS);

// stuff for storing the mpu values
xyzFloat gyroValues;
xyzFloat accValues;

std::vector <xyzFloat> gyroWindow(200);
std::vector <xyzFloat> accWindow(200);

// init the gps object and set its uart pins 
TinyGPSPlus gps;
SoftwareSerial GpsSerial( RX, TX);

unsigned long heartbeatStart = 0;
unsigned long mpuStart = 0;
unsigned long anomalyLastDetected = 0;

bool notFirst = false;

// ============================================================================ Setup ==================================================================================
void setup() 
{
    Wire.begin(i2cSDA, i2cSCL);
    Serial.begin(19200);
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
            blink(ledPin, 9);
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

void loop() 
{
    // don't worry about timer rollover as I did: https://arduino.stackexchange.com/questions/12587/how-can-i-handle-the-millis-rollover 
    // heartbeat ever 1000ms
    if( (millis() - heartbeatStart) >= 1000)
    {   
        heartbeatStart=millis();
        // ! comment this out later to speed up the loop
        Serial.println(".........................................................heartbeat...............................................................");
        blink(ledPin, 1);
    }

    // poll mpu sensors every POLL_INTERVAL ms
    if ((millis() - mpuStart) >= POLL_INTERVAL)
    {     
        updateMpu(mpu, gyroValues, accValues);   
        
        // add new values to the window
        gyroWindow.push_back(gyroValues);
        accWindow.push_back(accValues);

        // remove old values from the window
        gyroWindow.erase(gyroWindow.begin());
        accWindow.erase(accWindow.begin());

        if(isAnomaly(accWindow, THRESHOLD) and ((millis() - anomalyLastDetected) >= ANOMALY_DETECTION_COOLDOWN)) 
        {
            if(notFirst)
            {           
                // ! do something here 
                updateGPS(GpsSerial, gps);
                // send window somehow
                // ! REMOVE BEFORE DEPLOYING
                Serial.println("========================================================================================================================");
                Serial.println("===========================================   anomaly detected   =======================================================");
                Serial.println("========================================================================================================================");

                anomalyLastDetected = millis();
                blink(ledPin, 3);
            }
            notFirst = true;
        }    
        mpuStart = millis();
    }
}

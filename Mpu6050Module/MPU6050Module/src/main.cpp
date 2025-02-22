#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <MPU9250_WE.h>
#include <vector>

#include "utils.h"

// ==================================================================== Params ========================================================================

#define IMU_ADDRESS 0x68

// I2C pins for the mpu6500 Module
#define i2cSDA 4
#define i2cSCL 5

// UART pins for the gps module
#define RX 14
#define TX 12

// Status LED pin
#define ledPin 2

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

// The number of potential anomalies to store in a buffer before sending all back
#define POTENTIAL_ANOMALY_BUFFER_SIZE 6

// ----------------------------------------------------------------- Declarations ----------------------------------------------------------------------

MPU9250_WE mpu = MPU9250_WE(IMU_ADDRESS);

// custom struct for storing the gps location, and only location
gpsLocation gpsLoc;

// stuff for storing the mpu values
xyzFloat gyroValues;
xyzFloat accValues;

std::vector<xyzFloat> gyroWindow(200);
std::vector<xyzFloat> accWindow(200);

// ! I'll change this later to write to the file system instead, as a csv
std::vector<std::vector<xyzFloat>> gyroBuffer(POTENTIAL_ANOMALY_BUFFER_SIZE, std::vector<xyzFloat>(200));
std::vector<std::vector<xyzFloat>> accBuffer(POTENTIAL_ANOMALY_BUFFER_SIZE, std::vector<xyzFloat>(200));
std::vector<gpsLocation> gpsBuffer(POTENTIAL_ANOMALY_BUFFER_SIZE);

// init the gps object and set its uart pins
TinyGPSPlus gps;
SoftwareSerial GpsSerial(RX, TX);

unsigned long heartbeatStart = 0;
unsigned long mpuStart = 0;
unsigned long anomalyLastDetected = 0;

bool notFirst = false;
bool heartBeat = false;

// ============================================================================ Setup ==================================================================================
void setup()
{

    // todo ---------------------------------------------------------- Memory allocation Test, REMOVE LATER --------------------------------------------------
    //  currently each anomaly needs 4808 Bytes of memory
    //  This esp8266 has about 4,77,889 Bytes of usable flash memory.. hmm
    //  that means we could store about 99 anomalies in memory
    //  OH wait I forgot to acount for the wifi libraries that we'll need at some point.... ugh
    //  on further research I found out that it can have a max flash size of 512KB.... ugh
    //  which means max flash size = 5,24,288 B ... uhh... WHAT?
    //  ! mahu has shown me the way
    //  correct max number of anomalies that can be stored, using the max possible flash size (for my chip) of 512KB:
    //  new max number of anomalies that can be stored:
    //  109 anomalies approx... hmm

    for (uint8_t i = 0; i < POTENTIAL_ANOMALY_BUFFER_SIZE; i++)
    {
        gyroBuffer[i].reserve(200);
        accBuffer[i].reserve(200);
    }

    gyroWindow.reserve(200);
    accWindow.reserve(200);
    gpsBuffer.reserve(POTENTIAL_ANOMALY_BUFFER_SIZE);
    // todod ---------------------------------------------------------------------------------------------------------------------------------------------------

    Wire.begin(i2cSDA, i2cSCL);
    Serial.begin(19200);
    GpsSerial.begin(GPS_BAUD);

    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, HIGH);

    delay(500);
    Serial.println("Serial communication Begun:");

    if (mpu.init())
        Serial.println("MPU initialised");
    else
    {
        Serial.println("Error initialising MPU");

        blink(ledPin, 9);
        delay(500);
    }

    Serial.println("Calibrating MPU, keep it level and DONT MOVE IT");
    delay(1000);
    mpu.autoOffsets();
    Serial.println("Done!");

    // ================================== Digital Filter stuff ====================================
    mpu.enableGyrDLPF();
    mpu.setGyrDLPF(MPU9250_DLPF_6); // lowest noise
    mpu.setGyrRange(MPU9250_GYRO_RANGE_500);
    mpu.setAccRange(MPU9250_ACC_RANGE_4G);
    mpu.enableAccDLPF(true);
    mpu.setAccDLPF(MPU9250_DLPF_6); // lowest noise
}

// ================================================================================== MAIN LOOP ============================================================================

void loop()
{
    // don't worry about timer rollover as I did: https://arduino.stackexchange.com/questions/12587/how-can-i-handle-the-millis-rollover
    // heartbeat ever 1000ms
    if ((millis() - heartbeatStart) >= 1000)
    {
        heartbeatStart = millis();
        heartBeat = true;
        // ! comment this out later to speed up the loop
        Serial.println(".........................................................heartbeat...............................................................");
        // blink(ledPin, 1);
        // using above blink would cause a delay of 150ms at least, hence using a hopefully non-blocking blink
    }

    if (heartBeat)
    {
        if ((millis() - heartbeatStart) <= 100)
            digitalWrite(ledPin, HIGH);
        else
        {
            digitalWrite(ledPin, LOW);
            heartBeat = false;
        }
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

        if (isAnomaly(accWindow, THRESHOLD) and ((millis() - anomalyLastDetected) >= ANOMALY_DETECTION_COOLDOWN))
        {
            if (notFirst)
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

#include <Arduino.h>

#include <TinyGPSPlus.h>
#include <MPU9250_WE.h>

#include <SoftwareSerial.h>
#include <Wire.h>

#include <vector>

#include <FS.h>
#include <LittleFS.h>

#include <ESP8266WiFi.h>

#include "utils.h"
#include "secrets.h"

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
#define CONSERVATIVE_THRESOLD 12

bool conservativeMode = false;

// The number of ms to wait after detecting an anomaly,
// before being able to send another
#define ANOMALY_DETECTION_COOLDOWN 5000

// The number of potential anomalies to store in a buffer before sending all back
#define ANOMALY_BUFFER_SIZE 4

// The number of anomalies to send in one batch, back to the server in a single POST request
#define ANOMALY_BATCH_SIZE 2

// ----------------------------------------------------------------- Declarations ----------------------------------------------------------------------

MPU9250_WE mpu = MPU9250_WE(IMU_ADDRESS);

// custom struct for storing the gps location, and only location
gpsLocation gpsLoc;

// struct for storing the mpu values
xyzFloat accValues;

// vector to act as a sliding window to store the acc values
std::vector<xyzFloat> accWindow(200);

// init the gps object and set its uart pins
TinyGPSPlus gps;
SoftwareSerial GpsSerial(RX, TX);

// counters to store timer values
unsigned long heartbeatStart = 0;
unsigned long mpuStart = 0;
unsigned long anomalyLastDetected = 0;

// some flags to store some states for using non-blocking stuff in the main loop
bool notFirst = false;
bool heartBeat = false;

// counter for storing how many anomalies have been detected
uint16_t anomalyCounter = 0;

// path to store the detected anomalies in
const char *filePath = "anomalies.txt";

// Server URL:
const char *url = "http://192.168.1.9:8000";

// ============================================================================ Setup ==================================================================================
void setup()
{

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
    // now using only acc data, so it should be about double this, approximately

    // LittleFS.format();
    LittleFS.begin();
    LittleFS.format();

    Wire.begin(i2cSDA, i2cSCL);
    Serial.begin(19200);
    GpsSerial.begin(GPS_BAUD);

    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, HIGH);

    delay(1500);
    Serial.println("Serial communication Begun:");

    mpu.init();
    delay(100);

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

    // set the module to act as a station (a normal device that can connect to other networks)
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);
    // WiFi.begin();
    Serial.println("Connecting");

    uint8_t i = 0;

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
        i++;
        if (i > 100)
        {
            Serial.print("failed to connect, restarting esp");
            ESP.restart();
            break;
        }
    }

    Serial.println(WiFi.localIP());

    // setup wifi to auto re-connect whenever the network is available again
    WiFi.setAutoReconnect(true);
    WiFi.persistent(true);

    blink(ledPin, 6);
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
        // !----------------------------- comment this out later to speed up the loop ----------------------------------------------------------
        Serial.println(".........................................................heartbeat...............................................................");
        // blink(ledPin, 1);
        // using above blink would cause a delay of 150ms at least, hence using a hopefully non-blocking blink
    }

    if (heartBeat)
    {
        if ((millis() - heartbeatStart) <= 100)
            digitalWrite(ledPin, LOW);
        else
        {
            digitalWrite(ledPin, HIGH);
            heartBeat = false;
        }
    }

    // poll mpu sensors every POLL_INTERVAL ms
    if ((millis() - mpuStart) >= POLL_INTERVAL)
    {
        updateMpu(mpu, accValues);

        // add new values to the window
        accWindow.push_back(accValues);

        // remove old values from the window
        accWindow.erase(accWindow.begin());

        bool detected = false;

        if (!conservativeMode)
            detected = isAnomaly(accWindow, THRESHOLD);
        else
            detected = isAnomaly(accWindow, CONSERVATIVE_THRESOLD);

        if (detected and ((millis() - anomalyLastDetected) >= ANOMALY_DETECTION_COOLDOWN))
        {
            if (notFirst)
            {
                updateGPS(GpsSerial, gps);

                // ! REMOVE BEFORE DEPLOYING
                Serial.println("========================================================================================================================");
                Serial.println("===========================================   anomaly detected   =======================================================");
                Serial.println("========================================================================================================================");
                anomalyLastDetected = millis();
                blink(ledPin, 3);

                // if the buffer is 80% full, increase the threshold
                if (!conservativeMode and anomalyCounter >= (0.8 * ANOMALY_BUFFER_SIZE))
                {
                    conservativeMode = true;
                }

                // if (addToBuffer(accWindow, gps, LittleFS, anomalyCounter, ANOMALY_BUFFER_SIZE) == -5)
                //     Serial.println("Error adding to bffer");

                anomalyCounter++;
                Serial.print("AnomalyCOunter=");
                Serial.println(anomalyCounter);

                // if the anomaly buffer is full, send all the anomalies:
                if (anomalyCounter >= ANOMALY_BUFFER_SIZE)
                {
                    // send all the anomalies now:
                    int response = sendData(url, LittleFS, anomalyCounter, ANOMALY_BATCH_SIZE, ANOMALY_BUFFER_SIZE);

                    if (response != 200)
                    {
                        Serial.println("ERROR SENDING DATA with error code: " + response);
                    }

                    anomalyCounter = 0;
                }
            }
            notFirst = true;
        }
        mpuStart = millis();
    }
}

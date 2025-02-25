#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <MPU9250_WE.h>
#include <SoftwareSerial.h>
#include <FS.h>

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>

#include "utils.h"

// ### Blink ledPin n times, rapidly
// ##### Make sure to set ledPin as output beforehand
// #### Args:
// ledPin: The pin number to blink
// n: The number of times to blink the led
void blink(const uint8_t &ledPin, const uint8_t &n)
{
    for (uint8_t i = 0; i < n; i++)
    {
        digitalWrite(ledPin, LOW);
        delay(100);
        digitalWrite(ledPin, HIGH);
        delay(50);
    }
}

// ### Print whatever data the GPS object has currently,
// WITHOUT UPDATING IT
// #### Args:
// GpsSerial: The soft serial object used for communicating with the gps
// gps: The gps object of the tinyGPSPlus library
void printGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps)
{
    if (gps.location.isUpdated())
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

// ### Print the current mpu values,
// WITHOUT UPDATING IT
// #### Args:
// mpu: the mpu object
// corrGyrRaw: the raw gyro values
// aValues: the raw acceleration values in each axis, in m/s^2
void printMpu(MPU9250_WE &mpu, xyzFloat &corrGyrRaw, xyzFloat &gValue)
{
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

// ### update the gps object to the current values
// #### Args:
// GpsSerial: The soft serial object used for communicating with the gps
// gps: The gps object of the tinyGPSPlus library
void updateGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps)
{
    while (GpsSerial.available() > 0)
    {
        gps.encode(GpsSerial.read());
    }
}

// ### Update the mpu values to the current values
// #### Args:
// mpu: the mpu object
// corrGyrRaw: the raw gyro values
// aValues: the raw acceleration values in each axis, in m/s^2
void updateMpu(MPU9250_WE &mpu, xyzFloat &corrGyrRaw, xyzFloat &aValue)
{
    corrGyrRaw = mpu.getCorrectedGyrRawValues();
    aValue = mpu.getGValues();

    aValue.x *= 9.806;
    aValue.y *= 9.806;
    aValue.z *= 9.806;
}

// ### Checks if the current contents of the buffer have an anomaly or not
// #### Args:
// accWindow: The datastructure used to store the sliding window over the accelerometer data
// THRESHOLD: The threshold used for the Z Diff algorithm
bool isAnomaly(const std::vector<xyzFloat> &accWindow, const uint8_t &THRESHOLD)
{
    if (abs(accWindow[103].z - accWindow[97].z) >= THRESHOLD)
        return true;
    else
        return false;
}

// ### Adds the current acceleration and gyro windows to the Buffer (A simple text file in the flash filesystem)
// #### Args:
// pretty self explanatory I think?
bool addToBuffer(const std::vector<xyzFloat> &accWindow, const std::vector<xyzFloat> &gyroWindow, TinyGPSPlus &gps, fs::FS &fs, const char *path)
{
    File file = fs.open(path, "a");

    if (!file)
    {
        // failed to open file
        return false;
    }

    for (uint8_t i = 0; i < accWindow.size(); i++)
    {
        file.print(accWindow[i].x);
        file.print(" ");
        file.print(accWindow[i].y);
        file.print(" ");
        file.print(accWindow[i].z);
        file.print(" ");

        file.print(gyroWindow[i].x);
        file.print(" ");
        file.print(gyroWindow[i].y);
        file.print(" ");
        file.print(gyroWindow[i].z);
        file.print("\n");
    }

    file.print(float(gps.location.lat()));
    file.print(" ");
    file.print(float(gps.location.lng()));
    file.print("\n");

    file.close();
    return true;
}

int sendData(const ESP8266WiFiClass &wifi, const char *url, fs::FS &fs, const char *path)
{
    if (WiFi.status() == WL_CONNECTED)
    {
        WiFiClient client;
        HTTPClient http;

        http.begin(client, url);

        // ! ======================== add parsing here, to convert the txt from the buffer to a json =======================================
        String json = "";
        // !================================================================================================================================

        http.addHeader("Content-Type", "application/json");
        int httpResponseCode = http.POST(json);

        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);

        // Free resources
        http.end();

        return httpResponseCode;
    }
    else
    {
        Serial.println("WiFi Disconnected");
        return 0;
    }
}
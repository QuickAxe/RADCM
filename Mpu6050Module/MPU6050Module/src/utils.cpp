#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <MPU9250_WE.h>
#include <SoftwareSerial.h>
#include <FS.h>

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>

#include <ArduinoJson.h>

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
void printMpu(MPU9250_WE &mpu, xyzFloat &gValue)
{
    Serial.println("m/s values (x,y,z):");
    Serial.print(gValue.x * 9.806);
    Serial.print("   ");
    Serial.print(gValue.y * 9.806);
    Serial.print("   ");
    Serial.println(gValue.z * 9.806);
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
void updateMpu(MPU9250_WE &mpu, xyzFloat &aValue)
{
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
bool addToBuffer(const std::vector<xyzFloat> &accWindow, TinyGPSPlus &gps, fs::FS &fs, const char *path)
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
        file.print("\n");
    }

    file.print(float(gps.location.lat()));
    file.print(" ");
    file.print(float(gps.location.lng()));
    file.print(" ");
    file.print("\n");

    file.close();
    return true;
}

// ### Send *ALL* the anomalies back to the server, batchSize number at a time, so that it fits in RAM
// ### Make sure a wifi connection has been instantiated before, I think? should I do it here?
// #### Returns:
// http response code if everything goes ok (should be 200)
// -1 if there's no active wifi network connected to
// -2 if there's an error sending any batch of anomalies
// -3 if the buffer file failed to be deleted
// #### Args:
// wifi: wifi object
// url: url of the server to send the POST request to
// fs: the fs object
// path: path to the buffer file
// anomalycounter: self explanatory
// batchSize: How many anomalies to sent in one POST request
int sendData(const char *url, fs::FS &fs, const char *path, const uint8_t &anomalyCounter, const uint8_t &batchSize)
{
    if (WiFi.status() == WL_CONNECTED)
    {
        WiFiClient client;
        HTTPClient http;

        int httpResponseCode;

        http.begin(client, url);

        File file = fs.open(path, "r");

        if (!file)
        {
            // failed to open file
            return false;
        }

        // loop to send all anomalies in the buffer, one batchSize at a time
        for (uint8_t i = 0; i < anomalyCounter; i++)
        {
            // make the json doc and pack it with anomalies
            DynamicJsonDocument doc(4900);
            doc["source"] = "jimmy";

            // now add batchSize number of anomalies to the json doc:
            for (uint8_t j = 0; j < batchSize; j++)
            {
                String temp;

                // read one anomaly at a time
                for (uint8_t k = 0; k < 200; k++)
                {
                    // read each of the axes from the file, separated by a ' '

                    // x
                    temp = file.readStringUntil(' ');
                    doc["anomaly_data"][j]["window"][k][0] = temp.toFloat();

                    // y
                    temp = file.readStringUntil(' ');
                    doc["anomaly_data"][j]["window"][k][1] = temp.toFloat();

                    // z
                    temp = file.readStringUntil(' ');
                    doc["anomaly_data"][j]["window"][k][2] = temp.toFloat();

                    // discard that \n at the end
                    file.read();
                }

                // read the GPS location now
                temp = file.readStringUntil(' ');
                doc["anomaly_data"][j]["Latitude"] = temp.toFloat();
                temp = file.readStringUntil(' ');
                doc["anomaly_data"][j]["Longitude"] = temp.toFloat();

                // increment the anomaly counter as an anomaly hath been read
                i++;
            }

            // adding braces here so as to destroy buffer ( the string) as soon as it's done being used, to save memory
            // some hacks using a weird scope, I know, but this must be done :)
            {
                String buffer;
                serializeJson(doc, buffer);

                // send the data to the server now:
                http.addHeader("Content-Type", "application/json");
                httpResponseCode = http.POST(buffer);

                // Serial.print("HTTP Response code: ");
                // Serial.println(httpResponseCode);
            }

            if (httpResponseCode != 200)
                return -2;
        }

        // Free resources
        http.end();

        if (httpResponseCode == 200)
        {
            // delete the buffer file
            if (!fs.remove(path))
            {
                return -3;
            }
        }

        return httpResponseCode;
    }
    else
    {
        // Serial.println("WiFi Disconnected");
        return -1;
    }
}
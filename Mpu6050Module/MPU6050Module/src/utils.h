#pragma once

void blink(const uint8_t &ledPin, const uint8_t &n);
void printMpu(MPU9250_WE &mpu, xyzFloat &gValue);
void printGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps);

void updateMpu(MPU9250_WE &mpu, xyzFloat &gValue);
void updateGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps);

bool isAnomaly(const std::vector<xyzFloat> &accWindow, const uint8_t &);

bool addToBuffer(const std::vector<xyzFloat> &accWindow, TinyGPSPlus &gps, fs::FS &fs, const uint8_t &anomalyCounter, const uint8_t &ANOMALY_BUFFER_SIZE);
uint16_t sendData(const char *url, fs::FS &fs, const uint8_t &anomalyCounter, const uint8_t &batchSize, const uint8_t ANOMALY_BUFFER_SIZE);
struct gpsLocation
{
    double lat;
    double lng;
};
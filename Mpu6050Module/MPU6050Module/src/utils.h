#pragma once

void blink(const uint8_t &ledPin, const uint8_t &n);
void printMpu(MPU9250_WE &mpu, xyzFloat &gValue);
void printGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps);

void updateMpu(MPU9250_WE &mpu, xyzFloat &gValue);
void updateGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps);

bool isAnomaly(const std::vector<xyzFloat> &accWindow, const uint8_t &);

bool addToBuffer(const std::vector<xyzFloat> &accWindow, TinyGPSPlus &gps, fs::FS &fs, const char *path);
int sendData(const char *url, fs::FS &fs, const char *path, const uint8_t &anomalyCounter, const uint8_t &batchSize);
struct gpsLocation
{
    double lat;
    double lng;
};
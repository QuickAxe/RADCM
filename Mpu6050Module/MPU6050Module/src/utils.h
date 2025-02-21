#pragma once

void blink(const uint8_t &ledPin, const uint8_t &n);
void printMpu(MPU9250_WE &mpu, xyzFloat &corrGyrRaw, xyzFloat &gValue);
void printGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps);

void updateMpu(MPU9250_WE &mpu, xyzFloat &corrGyrRaw, xyzFloat &gValue);
void updateGPS(SoftwareSerial &GpsSerial, TinyGPSPlus &gps);

bool isAnomaly(const std::vector <xyzFloat> &accWindow, const uint8_t &);
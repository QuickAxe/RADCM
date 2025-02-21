// #include <Arduino.h>
// #include <TinyGPSPlus.h>
// #include <MPU9250_WE.h>
#pragma once
void blink(const uint8_t &, const uint8_t &);
void printMpu(MPU9250_WE &, xyzFloat &, xyzFloat &);
void printGPS(SoftwareSerial &, TinyGPSPlus &);
#include <Arduino.h>
#include <TinyGPSPlus.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <MPU9250_WE.h>

#define IMU_ADDRESS 0x68    //Change to the address of the IMU
#define PERFORM_CALIBRATION //Comment out this line to skip calibration at start

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

// ================================================================= Utility Functions ============================================================================
void blink(uint8_t n)
{
    for(uint8_t i=0; i<n; i++)
    {
        digitalWrite(ledPin, HIGH);
        delay(100);
        digitalWrite(ledPin, LOW);
        delay(50);
    }
}

void displayInfo()
{
  Serial.print(F("Location: ")); 
  if (gps.location.isValid())
  {
    Serial.print(gps.location.lat(), 6);
    Serial.print(F(","));
    Serial.print(gps.location.lng(), 6);
  }
  else
  {
    Serial.print(F("INVALID"));
  }

  Serial.print(F("  Date/Time: "));
  if (gps.date.isValid())
  {
    Serial.print(gps.date.month());
    Serial.print(F("/"));
    Serial.print(gps.date.day());
    Serial.print(F("/"));
    Serial.print(gps.date.year());
  }
  else
  {
    Serial.print(F("INVALID"));
  }

  Serial.print(F(" "));
  if (gps.time.isValid())
  {
    if (gps.time.hour() < 10) Serial.print(F("0"));
    Serial.print(gps.time.hour());
    Serial.print(F(":"));
    if (gps.time.minute() < 10) Serial.print(F("0"));
    Serial.print(gps.time.minute());
    Serial.print(F(":"));
    if (gps.time.second() < 10) Serial.print(F("0"));
    Serial.print(gps.time.second());
    Serial.print(F("."));
    if (gps.time.centisecond() < 10) Serial.print(F("0"));
    Serial.print(gps.time.centisecond());
  }
  else
  {
    Serial.print(F("INVALID"));
  }

  Serial.println();
}

void printGPS()
{
    while(GpsSerial.available() > 0)
    {
        gps.encode(GpsSerial.read());
        // Serial.print(char(GpsSerial.read()));
    }
    
    if(gps.location.isUpdated())
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

void printMpu()
{
    corrGyrRaw = mpu.getCorrectedGyrRawValues();
    gValue = mpu.getGValues();
  
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
            blink(6);
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

    printGPS();
    printMpu();

}

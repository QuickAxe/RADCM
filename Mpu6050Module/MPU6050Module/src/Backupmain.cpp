// #include <Arduino.h>
// #include <TinyGPSPlus.h>
// #include <SoftwareSerial.h>
// #include <Wire.h>
// #include <FastIMU.h>

// #define IMU_ADDRESS 0x68    //Change to the address of the IMU
// #define PERFORM_CALIBRATION //Comment out this line to skip calibration at start

// #define i2cSDA 4
// #define i2cSCL 5

// #define RX 14
// #define TX 12

// //! configure this later
// #define ledPin 3

// #define GPS_BAUD 9600

// MPU6500 mpu;

// // ! -----------------------------
// // TinyGPSPlus gps;
// // SoftwareSerial GpsSerial( RX, TX);

// calData calib = { 0 };  //Calibration data
// AccelData accelData;    //Sensor data
// GyroData gyroData;


// void blink(uint8_t n)
// {
//     for(uint8_t i=0; i<n; i++)
//     {
//         digitalWrite(ledPin, HIGH);
//         delay(100);
//         digitalWrite(ledPin, LOW);
//         delay(50);
//     }
// }

// // void printGPS()
// // {
// //     if(GpsSerial.available())
// //     {
// //         gps.encode(GpsSerial.read());
// //         // Serial.print(char(GpsSerial.read()));
// //     }
    
// //     if(gps.location.isUpdated())
// //     {
// //         Serial.print("LAT: ");
// //         Serial.println(gps.location.lat(), 6);
// //         Serial.print("LONG: "); 
// //         Serial.println(gps.location.lng(), 6);
// //         Serial.print("SPEED (km/h) = "); 
// //         Serial.println(gps.speed.kmph()); 
// //         Serial.print("ALT (min)= "); 
// //         Serial.println(gps.altitude.meters());
// //         Serial.print("HDOP = "); 
// //         Serial.println(gps.hdop.value() / 100.0); 
// //         Serial.print("Satellites = "); 
// //         Serial.println(gps.satellites.value()); 
// //         Serial.print("Time in UTC: ");
// //         Serial.println(String(gps.date.year()) + "/" + String(gps.date.month()) + "/" + String(gps.date.day()) + "," + String(gps.time.hour()) + ":" + String(gps.time.minute()) + ":" + String(gps.time.second()));
// //         Serial.println("");
// //     }
// // }


// void setup() 
// {
//     Wire.begin(i2cSDA, i2cSCL);
//     Serial.begin(9600);

//     // !------------------------
//     // GpsSerial.begin(GPS_BAUD);

//     pinMode(ledPin, OUTPUT);

//     delay(100);

//     // while(not Serial);
//     Serial.println("Serial communication Begun:");

//     // check if the imu has connected, otherwise throw an error
//     int err = mpu.init(calib, IMU_ADDRESS);
//     if (err != 0)
//     {
//       Serial.print("Error initializing IMU: ");
//       Serial.println(err);
//       blink(6);
//       while(true);      
//     }

//     #ifdef PERFORM_CALIBRATION
//         Serial.println("Callibrating IMU:");
//         delay(1000);
//         Serial.println("Keep IMU level.");
//         delay(2500);
//         mpu.calibrateAccelGyro(&calib);
//         Serial.println("Calibration done!");
//         Serial.println("Accel biases X/Y/Z: ");
//         Serial.print(calib.accelBias[0]);
//         Serial.print(", ");
//         Serial.print(calib.accelBias[1]);
//         Serial.print(", ");
//         Serial.println(calib.accelBias[2]);
//         Serial.println("Gyro biases X/Y/Z: ");
//         Serial.print(calib.gyroBias[0]);
//         Serial.print(", ");
//         Serial.print(calib.gyroBias[1]);
//         Serial.print(", ");
//         Serial.println(calib.gyroBias[2]);
//         delay(5000);
//         mpu.init(calib, IMU_ADDRESS);
//     #endif

//     err = mpu.setGyroRange(500);      //USE THESE TO SET THE RANGE, IF AN INVALID RANGE IS SET IT WILL RETURN -1
//     err = mpu.setAccelRange(4);       //THESE TWO SET THE GYRO RANGE TO ±500 DPS AND THE ACCELEROMETER RANGE TO ±4g
 
//     if (err != 0)
//     {
//         Serial.print("Error Setting range: ");
//         Serial.println(err);
//         blink(6);
//         while(true);
//     }
// }


// unsigned long start = 0;
// void loop() 
// {
//     if( (millis() - start) >= 1000)
//     {   
//         start=millis();
//         Serial.println("...........................heartbeat............................................");
//     }

//     mpu.update();
//     mpu.getAccel(&accelData);
//     Serial.print("Accel - x:");
//     Serial.print(accelData.accelX);
//     Serial.print("\t");
//     Serial.print("y:");
//     Serial.print(accelData.accelY);
//     Serial.print("\t");
//     Serial.print("z:");
//     Serial.print(accelData.accelZ);
//     Serial.print("\t");
//     mpu.getGyro(&gyroData);
//     Serial.print("Gyro - x:");
//     Serial.print(gyroData.gyroX);
//     Serial.print("\t");
//     Serial.print("y:");
//     Serial.print(gyroData.gyroY);
//     Serial.print("\t");
//     Serial.print("z:");
//     Serial.print(gyroData.gyroZ);
//     if (mpu.hasTemperature()) {
//         Serial.print("\t");
//       Serial.print("Temp:");
//         Serial.println(mpu.getTemp());
//     }
//     delay(150);

// }

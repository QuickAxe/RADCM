import 'package:admin_app/pages/survey/survey_control_screen.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Start a Survey",
          style: context.theme.textTheme.titleLarge,
        ),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates, // fires once per qr
        ),
        // onDetect is run when a qrcode is detected
        onDetect: (capture) async {
          // check if wifi is enabled
          bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();

          if (isWifiEnabled) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final qrCode = barcode.rawValue;
              if (qrCode == null) return;

              print(
                  "------------------------------------------ QR Code: $qrCode ------------------------------------------");

              // Format -> 'WIFI:S:SUPERIOR;T:WPA;P:12345678;H:false;;';
              bool isWifiConnectionAttempted = false;

              // break the qr into a list of its components
              List<String> qrCodeSplit = qrCode.split(';');
              if (qrCodeSplit.length >= 3) {
                String ssid = qrCodeSplit[0].split(':')[2];
                String password = qrCodeSplit[2].split(':')[1];

                // connect to wifi
                isWifiConnectionAttempted = await WiFiForIoTPlugin.connect(ssid,
                    password: password,
                    security: NetworkSecurity.WPA,
                    withInternet: false);
              }

              if (isWifiConnectionAttempted) {
                bool isWifiConnected = false;
                print("-----------------------------> ATTEMPT SUCCESS");

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text("Connecting to Wi-Fi..."),
                        ],
                      ),
                    );
                  },
                );

                final startTime = DateTime.now();
                const timeout = Duration(seconds: 10);


                do {
                  isWifiConnected = await WiFiForIoTPlugin.isConnected();
                  if (DateTime.now().difference(startTime) > timeout) {
                    break;
                  } else {
                    await Future.delayed(const Duration(seconds: 1));
                  }
                }while (isWifiConnected == false);

                Navigator.of(context).pop();

                if(isWifiConnected) {
                  Fluttertoast.showToast(
                    msg: "Connection successful",
                    toastLength: Toast.LENGTH_LONG,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const SurveyControlScreen()),
                  );
                }
                else {
                  Fluttertoast.showToast(
                    msg: "Error - connection timed out, please retry",
                    toastLength: Toast.LENGTH_LONG,
                  );
                  Navigator.of(context).pop();
                }
              } else {
                print("-----------------------------> FAIL");
                Fluttertoast.showToast(
                  msg: "Error - couldn't connect to Wi-Fi, please retry",
                  toastLength: Toast.LENGTH_LONG,
                );
              }
            }
          }
        },
      ),
    );
  }
}

import 'package:admin_app/pages/survey/survey_control_screen.dart';
import 'package:admin_app/services/wifi_qr_code.dart';
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

              final qrCodeDisassembler = WifiQrCode(qrCode);

              print(
                  "------------------------------------------ QR Code: ${qrCodeDisassembler.qrCode} ------------------------------------------");

              if (qrCodeDisassembler.fields.containsKey('S') &&
                  qrCodeDisassembler.fields.containsKey('P')) {
                // show connection attempt dialog
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

                bool isWifiConnectionAttempted =
                    await qrCodeDisassembler.attemptWifiConnection();

                if (isWifiConnectionAttempted) {
                  bool isWifiConnected = await WiFiForIoTPlugin.isConnected();
                  print("-----------------------------> SUCCESS");

                  Navigator.of(context).pop();
                  if (isWifiConnected) {
                    Fluttertoast.showToast(
                      msg: "Connection successful",
                      toastLength: Toast.LENGTH_LONG,
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const SurveyControlScreen()),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Error - connection timed out, please retry",
                      toastLength: Toast.LENGTH_LONG,
                    );
                    Navigator.of(context).pop();
                  }
                } else {
                  print("-----------------------------> FAIL");
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: "Error - couldn't connect to the Wi-Fi, please retry",
                    toastLength: Toast.LENGTH_LONG,
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: "why u playin ??",
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

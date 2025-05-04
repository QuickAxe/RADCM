import 'package:admin_app/pages/survey/survey_control_screen.dart';
import 'package:admin_app/services/wifi_qr_code.dart';
import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../../services/providers/user_settings.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  bool _isTorchOn = false;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<UserSettingsProvider>();
      if (settings.showSurveyInfo) {
        showSurveyHelpDialog(settings, context);
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isTorchOn = !_isTorchOn;
          });
          _scannerController.toggleTorch();
        },
        child: Icon(
            _isTorchOn ? LucideIcons.flashlightOff : LucideIcons.flashlight),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Start a Survey",
          style: context.theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
              onPressed: () {
                final settings = context.read<UserSettingsProvider>();
                showSurveyHelpDialog(settings, context);
              },
              icon: const Icon(Icons.question_mark_rounded))
        ],
      ),
      body: MobileScanner(
        controller: _scannerController,
        // onDetect is run when a qrcode is detected
        onDetect: (capture) async {
          if (_isTorchOn) {
            setState(() {
              _isTorchOn = !_isTorchOn;
            });
            _scannerController.toggleTorch();
          }

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

void showSurveyHelpDialog(UserSettingsProvider settings, BuildContext context) {
  bool doNotShowAgain = false;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        // backgroundColor: Colors.white,
        title: const Text("How to Start a Survey"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/uav.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              'To begin a survey, scan the QR code located on the UAV. '
              'This connects your device to the UAV over Wi-Fi.',
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Do not show this again"),
                  value: doNotShowAgain,
                  onChanged: (value) {
                    setState(() {
                      doNotShowAgain = value ?? false;
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (doNotShowAgain) {
                settings.setShowSurveyInfo(false);
              }
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

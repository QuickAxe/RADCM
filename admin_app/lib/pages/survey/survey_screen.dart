import 'package:admin_app/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
          detectionSpeed: DetectionSpeed
              .noDuplicates, // prevents the onDetect from firing continuously
        ),
        // onDetect is run when a qrcode is detected
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final raw = barcode.rawValue;
            if (raw == null) return;

            print("QR Code: $raw");

            // TODO: connect to wifi part
          }
        },
      ),
    );
  }
}

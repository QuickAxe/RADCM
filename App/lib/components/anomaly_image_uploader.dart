import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../services/api_service/dio_client_user_service.dart';

class AnomalyImageUploader extends StatefulWidget {
  @override
  _AnomalyImageUploaderState createState() => _AnomalyImageUploaderState();
}

class _AnomalyImageUploaderState extends State<AnomalyImageUploader> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final DioClientUser _dioClient = DioClientUser();

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_imageFile == null) {
      Fluttertoast.showToast(
        msg: "No image selected!",
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String fileName = basename(_imageFile!.path);

      // Example coordinates (replace with real GPS values)
      String latitude = "12.3456";
      String longitude = "77.6543";

      FormData formData = FormData();

      // Add fields (source, lat, lng)
      formData.fields.addAll([
        const MapEntry("source", "mobile"),
        MapEntry("lat", latitude),
        MapEntry("lng", longitude),
      ]);

      // Add image as a list-compatible entry
      formData.files.add(
        MapEntry(
          "image",
          await MultipartFile.fromFile(
            _imageFile!.path,
            filename: fileName,
            contentType: MediaType.parse(lookupMimeType(_imageFile!.path) ?? "image/jpeg"),
          ),
        ),
      );

      DioResponse response =
          await _dioClient.postRequest("anomalies/images/", formData);

      setState(() => _isUploading = false);

      if (response.success) {
        Fluttertoast.showToast(
            msg: "Anomaly submitted!", toastLength: Toast.LENGTH_SHORT);
        setState(() => _imageFile = null);
      } else {
        Fluttertoast.showToast(
            msg: "Something went wrong :/", toastLength: Toast.LENGTH_SHORT);
        log("Upload failed: ${response.errorMessage}");
      }
    } catch (e) {
      setState(() => _isUploading = false);
      Fluttertoast.showToast(
          msg: "An error occurred!", toastLength: Toast.LENGTH_SHORT);
      log('Error: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: _imageFile == null
                  ? DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(25.0),
                      dashPattern: const [8, 4],
                      color: colorScheme.outlineVariant,
                      strokeWidth: 2,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.fileQuestion,
                                size: 50, color: colorScheme.secondary),
                            const SizedBox(height: 30),
                            Text("Capture a picture of the anomaly",
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(25.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Column(
              children: [
                if (_imageFile == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20),
                      _buildActionButton(
                        icon: LucideIcons.camera,
                        label: "Capture",
                        onPressed: _captureImage,
                        buttonColor: colorScheme.primaryContainer,
                        iconColor: colorScheme.onPrimaryContainer,
                        textColor: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: LucideIcons.trash,
                        label: "Discard",
                        onPressed: _removeImage,
                        buttonColor: colorScheme.errorContainer,
                        iconColor: colorScheme.onErrorContainer,
                        textColor: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 20),
                      _isUploading
                          ? const CircularProgressIndicator()
                          : _buildActionButton(
                              icon: LucideIcons.upload,
                              label: "Submit",
                              onPressed: () => _uploadImage(context),
                              buttonColor: colorScheme.primaryContainer,
                              iconColor: colorScheme.onPrimaryContainer,
                              textColor: colorScheme.onPrimaryContainer,
                            ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color buttonColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: 22),
      label: Text(label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 6,
        shadowColor: Colors.black26,
      ),
    );
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:app/util/context_extensions.dart';
import 'package:app/util/general_utils.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  double? _latitude;
  double? _longitude;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final DioClientUser _dioClient = DioClientUser();
  double _uploadProgress = 0.0;

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      showToast("Fetching current location");
      Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) {
      return "No image selected";
    } else if (_latitude == null || _longitude == null) {
      return "No location data available";
    }

    setState(() => _isUploading = true);

    try {
      String fileName = basename(_imageFile!.path);

      String latitude = _latitude.toString();
      String longitude = _longitude.toString();

      FormData formData = FormData();

      formData.fields.addAll([
        const MapEntry("source", "mobile"),
        MapEntry("lat", latitude),
        MapEntry("lng", longitude),
      ]);

      // Add image as a list-compatible entry
      final mime = lookupMimeType(_imageFile!.path);
      final mimeSplit = mime?.split('/') ?? ['image', 'jpeg'];
      formData.files.add(
        MapEntry(
          "image",
          await MultipartFile.fromFile(
            _imageFile!.path,
            filename: fileName,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        ),
      );

      DioResponse response = await _dioClient.postRequest(
        "anomalies/images/",
        formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      setState(() => _isUploading = false);

      if (response.success) {
        return null;
      } else {
        log("Upload failed: ${response.errorMessage}");
        return "Something went wrong";
      }
    } catch (e) {
      setState(() => _isUploading = false);
      log('Error: $e');
      return "An error occured";
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _latitude = null;
      _longitude = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          if (_isUploading)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: LinearProgressIndicator(value: _uploadProgress),
                ),
                const SizedBox(height: 2),
              ],
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: _imageFile == null
                  ? DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(25.0),
                      dashPattern: const [8, 4],
                      color: context.colorScheme.outlineVariant,
                      strokeWidth: 2,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.fileQuestion,
                                size: 50, color: context.colorScheme.secondary),
                            const SizedBox(height: 30),
                            Text("Capture a picture of the anomaly",
                                style: context.theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colorScheme.outlineVariant,
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
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Column(
              children: [
                if (_imageFile == null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: context.colorScheme.primary,
                    ),
                    onPressed: _captureImage,
                    icon: Icon(Icons.camera_alt_rounded,
                        color: context.colorScheme.onPrimary),
                    label: Text(
                      'Capture',
                      style: context.theme.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      // remove image button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: _isUploading
                                ? context.colorScheme.onSurface.withOpacity(0.5)
                                : context.colorScheme.error,
                          ),
                          onPressed: _isUploading ? null : _removeImage,
                          icon: Icon(Icons.delete_outline,
                              color: context.colorScheme.onError),
                          label: Text(
                            'Discard',
                            style: context.theme.textTheme.labelLarge?.copyWith(
                              color: context.colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: _isUploading
                                ? context.colorScheme.onSurface.withOpacity(0.5)
                                : context.colorScheme.primary,
                          ),
                          onPressed: _isUploading
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      icon: const Icon(
                                          Icons.cloud_upload_rounded),
                                      title: const Text('Confirm Submit'),
                                      content: const Text(
                                          'You are about to submit an image and its associated location data.\n\nNOTE: The location data is not linked to your device and will only be used to display the anomaly on the map.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Yes, Submit'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    String? result = await _uploadImage();
                                    setState(() {
                                      _uploadProgress = 0.0;
                                      _isUploading = false;
                                    });
                                    if (result == null) {
                                      showSnackBar(
                                          "Anomaly image submitted successfully!",
                                          context);
                                    } else {
                                      showSnackBar(result, context);
                                    }
                                  }
                                },
                          icon: Icon(Icons.cloud_upload_rounded,
                              color: context.colorScheme.onPrimary),
                          label: Text(
                            'Submit',
                            style: context.theme.textTheme.labelLarge?.copyWith(
                              color: context.colorScheme.onPrimary,
                            ),
                          ),
                        ),
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
}

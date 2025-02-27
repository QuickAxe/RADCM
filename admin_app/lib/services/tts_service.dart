import 'package:admin_app/services/providers/user_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final UserSettingsProvider userSettings; // This is fetched from User Settings

  TtsService(this.userSettings) {
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setVoice({
      "name": userSettings.selectedVoice,
      "locale": userSettings.selectedLocale
    });
    await _flutterTts.setVolume(userSettings.voiceVolume);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(userSettings.speechRate);
  }

  Future<void> speak(String text) async {
    if (userSettings.voiceEnabled == false) return;
    await Future.delayed(const Duration(milliseconds: 1000)); // Avoid overlap
    await _flutterTts.speak(text);
  }

  Future<void> getVoices() async {
    List<dynamic> voices = await _flutterTts.getVoices;
    if (kDebugMode) {
      print(voices);
    }
  }
}

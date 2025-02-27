import 'package:app/services/providers/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserSettingsProvider Tests', () {
    late UserSettingsProvider userSettings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      userSettings = UserSettingsProvider();
    });

    test('Initial values are set correctly', () {
      expect(userSettings.voiceEnabled, true);
      expect(userSettings.selectedVoice, "en-gb-x-gbb-local");
      expect(userSettings.selectedLocale, "en-GB");
      expect(userSettings.voiceVolume, 1.0);
      expect(userSettings.speechRate, 0.6);
      expect(userSettings.autoDetectRoutines, false);
      expect(userSettings.profile, "driving");
      expect(userSettings.themeMode, ThemeMode.dark);
    });

    test('toggleVoiceEnabled switches value', () {
      userSettings.toggleVoiceEnabled();
      expect(userSettings.voiceEnabled, false);
      userSettings.toggleVoiceEnabled();
      expect(userSettings.voiceEnabled, true);
    });

    test('setSelectedVoice updates value', () {
      userSettings.setSelectedVoice("en-gb-x-gba-local");
      expect(userSettings.selectedVoice, "en-gb-x-gba-local");
    });

    test('setVoiceVolume updates value', () {
      userSettings.setVoiceVolume(0.8);
      expect(userSettings.voiceVolume, 0.8);
    });

    test('setSpeechRate updates value', () {
      userSettings.setSpeechRate(0.9);
      expect(userSettings.speechRate, 0.9);
    });

    test('toggleAutoDetectRoutines switches value', () {
      userSettings.toggleAutoDetectRoutines();
      expect(userSettings.autoDetectRoutines, true);
      userSettings.toggleAutoDetectRoutines();
      expect(userSettings.autoDetectRoutines, false);
    });

    test('setProfile updates value', () async {
      userSettings.setProfile("walking");
      expect(userSettings.profile, "walking");
    });

    test('setThemeMode updates value', () {
      userSettings.setThemeMode(ThemeMode.light);
      expect(userSettings.themeMode, ThemeMode.light);
    });

    test('toggleShowOnMap updates values', () {
      userSettings.toggleShowOnMap("Speedbreaker");
      expect(userSettings.showOnMap["Speedbreaker"], false);
    });

    test('toggleAlertWhileRiding updates values', () {
      userSettings.toggleAlertWhileRiding("Pothole");
      expect(userSettings.alertWhileRiding["Pothole"], false);
    });
  });
}

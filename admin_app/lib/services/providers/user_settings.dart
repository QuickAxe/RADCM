import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsProvider extends ChangeNotifier {
  // Voice engine settings
  String _selectedVoice = "default";
  String get selectedVoice => _selectedVoice;
  double _voiceVolume = 0.5; // TODO: Check back
  double get voiceVolume => _voiceVolume;

  void logout() {
    _selectedVoice = "default";
    _voiceVolume = 0.5;
    notifyListeners();
  }

  void setSelectedVoice(String voice) {
    _selectedVoice = voice;
    _savePreference("selectedVoice", voice);
    notifyListeners();
  }

  void setVoiceVolume(double volume) {
    _voiceVolume = volume;
    _savePreference("notificationVolume", volume);
    notifyListeners();
  }

  // Toggle anomalies provider
  final Map<String, bool> _showOnMap = {
    "Speedbreaker": true,
    "Rumbler": true,
    "Obstacle": true,
    "Pothole": true,
  };

  final Map<String, bool> _alertWhileRiding = {
    "Speedbreaker": true,
    "Rumbler": true,
    "Obstacle": true,
    "Pothole": true
  };

  Map<String, bool> get showOnMap => _showOnMap;
  Map<String, bool> get alertWhileRiding => _alertWhileRiding;

  void toggleShowOnMap(String anomaly) {
    _showOnMap[anomaly] = !_showOnMap[anomaly]!;
    _savePreference("showOnMap_$anomaly", _showOnMap[anomaly]!);
    notifyListeners();
  }

  void toggleAlertWhileRiding(String anomaly) {
    _alertWhileRiding[anomaly] = !_alertWhileRiding[anomaly]!;
    _savePreference("alertWhileRiding_$anomaly", _alertWhileRiding[anomaly]!);
    notifyListeners();
  }

  // auto detect routine
  bool _autoDetectRoutines = false;
  bool get autoDetectRoutines => _autoDetectRoutines;

  void toggleAutoDetectRoutines() {
    _autoDetectRoutines = !_autoDetectRoutines;
    _savePreference("autoDetectRoutines", _autoDetectRoutines);
    notifyListeners();
  }

  final List<Map<String, dynamic>> profiles = [
    {"name": "Driving", "value": "driving", "icon": Icons.directions_car},
    {"name": "Walking", "value": "walking", "icon": Icons.directions_walk},
    {"name": "Cycling", "value": "cycling", "icon": Icons.directions_bike},
  ];

  // Mode of transport preference (profile)
  String _profile = "driving";
  String get profile => _profile;

  Future<void> setProfile(String newProfile) async {
    _profile = newProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile", newProfile);
    notifyListeners();
  }

  // Theme Mode Setting
  ThemeMode _themeMode = ThemeMode.dark; // Default is system
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _savePreference("themeMode", mode.index); // Store as an integer
    notifyListeners();
  }

  UserSettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedVoice = prefs.getString("selectedVoice") ?? "default";
    _voiceVolume = prefs.getDouble("voiceVolume") ?? 0.5;

    for (var anomaly in _showOnMap.keys) {
      _showOnMap[anomaly] = prefs.getBool("showOnMap_$anomaly") ?? true;
      _alertWhileRiding[anomaly] =
          prefs.getBool("alertWhileRiding_$anomaly") ?? true;
    }

    _autoDetectRoutines = prefs.getBool("autoDetectRoutines") ?? false;
    _profile = prefs.getString("profile") ?? "driving";

    int themeIndex = prefs.getInt("themeMode") ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values[themeIndex]; // Convert int back to enum

    notifyListeners();
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }
}

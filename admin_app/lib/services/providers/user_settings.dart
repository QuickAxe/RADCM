import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsProvider extends ChangeNotifier {
  // Voice engine settings
  bool _voiceEnabled = true;
  bool get voiceEnabled => _voiceEnabled;
  String _selectedVoice = "en-gb-x-gbb-local";
  String get selectedVoice => _selectedVoice;
  String _selectedLocale = "en-GB";
  String get selectedLocale => _selectedLocale;
  double _voiceVolume = 1.0;
  double get voiceVolume => _voiceVolume;
  double _speechRate = 0.6;
  double get speechRate => _speechRate;

  void toggleVoiceEnabled() {
    _voiceEnabled = !_voiceEnabled;
    _savePreference("voiceEnabled", _voiceEnabled);
    notifyListeners();
  }

  void setSelectedVoice(String voice) {
    _selectedVoice = voice;
    _savePreference("selectedVoice", voice);
    notifyListeners();
  }

  void setSelectedLocale(String locale) {
    _selectedLocale = locale;
    _savePreference("selectedLocale", locale);
    notifyListeners();
  }

  void setVoiceVolume(double volume) {
    _voiceVolume = volume;
    _savePreference("notificationVolume", volume);
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    _savePreference("speechRate", rate);
    notifyListeners();
  }

  void logout() {
    _selectedVoice = "en-gb-x-gbb-local";
    _voiceVolume = 0.5;
    _speechRate = 0.5;
    _selectedLocale = "en-GB";
    notifyListeners();
  }

  /// Toggle anomalies provider
  final Map<String, bool> _showOnMap = {
    "SpeedBreaker": true,
    "Rumbler": true,
    "Pothole": true,
    "Cracks": true,
  };

  final Map<String, bool> _alertWhileRiding = {
    "SpeedBreaker": true,
    "Rumbler": true,
    "Pothole": true,
    "Cracks": true
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

  void setProfile(String newProfile) {
    _profile = newProfile;
    _savePreference("profile", newProfile);
    notifyListeners();
  }

  // Theme Mode Setting
  ThemeMode _themeMode = ThemeMode.light; // Default is system
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
    _voiceEnabled = prefs.getBool("voiceEnabled") ?? true;
    _selectedVoice = prefs.getString("selectedVoice") ?? "en-gb-x-gbb-local";
    _selectedLocale = prefs.getString("selectedLocale") ?? "en-GB";
    _voiceVolume = prefs.getDouble("voiceVolume") ?? 1.0;
    _speechRate = prefs.getDouble("speechRate") ?? 0.6;

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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsProvider extends ChangeNotifier {
  // Voice engine settings
  // gba means female and gbb means male
  String _selectedVoice = "en-gb-x-gbb-local";
  String get selectedVoice => _selectedVoice;
  String _selectedLocale = "en-GB";
  String get selectedLocale => _selectedLocale;
  double _voiceVolume = 0.5;
  double get voiceVolume => _voiceVolume;
  double _speechRate = 0.4;
  double get speechRate => _speechRate;

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
  ThemeMode _themeMode = ThemeMode.dark; // Default is dark
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
    _selectedLocale = prefs.getString("selectedLocale") ?? "en-GB";
    _voiceVolume = prefs.getDouble("voiceVolume") ?? 0.5;
    _speechRate = prefs.getDouble("speechRate") ?? 0.5;

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

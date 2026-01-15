import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

class SettingsService {
  static const String _settingsFileName = 'settings.json';
  static final SettingsService _instance = SettingsService._internal();
  
  factory SettingsService() {
    return _instance;
  }
  
  SettingsService._internal();
  
  Map<String, dynamic> _settings = {
    'firstLaunch': true,
    'darkMode': false,
    'language': 'zh_CN',
    'javaPath': '',
    'memory': 2048,
    'downloadSource': 'default',
  };
  
  Future<void> loadSettings() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File settingsFile = File('${appDocDir.path}/$_settingsFileName');
      
      if (await settingsFile.exists()) {
        final String jsonString = await settingsFile.readAsString();
        final Map<String, dynamic> loadedSettings = json.decode(jsonString);
        _settings.addAll(loadedSettings);
      } else {
        await saveSettings();
      }
    } catch (e) {
      logE('Failed to load settings:', e);
      // 使用默认设置
      await saveSettings();
    }
  }
  
  Future<void> saveSettings() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File settingsFile = File('${appDocDir.path}/$_settingsFileName');
      
      final String jsonString = json.encode(_settings);
      await settingsFile.writeAsString(jsonString);
    } catch (e) {
      logE('Failed to save settings:', e);
    }
  }
  
  // Getters
  bool get isFirstLaunch => _settings['firstLaunch'] as bool;
  bool get isDarkMode => _settings['darkMode'] as bool;
  String get language => _settings['language'] as String;
  String get javaPath => _settings['javaPath'] as String;
  int get memory => _settings['memory'] as int;
  String get downloadSource => _settings['downloadSource'] as String;
  
  // Setters
  set firstLaunch(bool value) {
    _settings['firstLaunch'] = value;
    saveSettings();
  }
  
  set darkMode(bool value) {
    _settings['darkMode'] = value;
    saveSettings();
  }
  
  set language(String value) {
    _settings['language'] = value;
    saveSettings();
  }
  
  set javaPath(String value) {
    _settings['javaPath'] = value;
    saveSettings();
  }
  
  set memory(int value) {
    _settings['memory'] = value;
    saveSettings();
  }
  
  set downloadSource(String value) {
    _settings['downloadSource'] = value;
    saveSettings();
  }
  
  // 重置设置
  Future<void> resetSettings() async {
    _settings = {
      'firstLaunch': false,
      'darkMode': false,
      'language': 'zh_CN',
      'javaPath': '',
      'memory': 2048,
      'downloadSource': 'default',
    };
    await saveSettings();
  }
}
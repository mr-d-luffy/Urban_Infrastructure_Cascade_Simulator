import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _prefKeyBaseUrl = 'custom_api_base_url';

  static String getDefaultBaseUrl() {
    // 1. Check if defined in .env
    final envUrl = dotenv.isInitialized ? dotenv.env['API_BASE_URL'] : null;
    if (envUrl != null && envUrl.trim().isNotEmpty) {
      return envUrl.trim().replaceAll(RegExp(r'/+$'), '');
    }

    // 2. Default platform fallbacks
    if (kIsWeb) {
      return 'https://urban-infrastructure-cascade-simulator.onrender.com';
    }
    if (Platform.isAndroid) {
      // Android emulator points to host loopback via 10.0.2.2
      return 'https://urban-infrastructure-cascade-simulator.onrender.com';
    }
    return 'https://urban-infrastructure-cascade-simulator.onrender.com';
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyBaseUrl) ?? getDefaultBaseUrl();
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyBaseUrl, url.trim().replaceAll(RegExp(r'/+$'), ''));
  }

  static Future<void> resetBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyBaseUrl);
  }
}

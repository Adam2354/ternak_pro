// lib/services/cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/TipsItem.dart';

class CacheService {
  static const String _userDataKey = 'cached_user_data';
  static const String _tasksDataKey = 'cached_tasks_data';
  static const String _lastCacheTimeKey = 'last_cache_time';
  static const String _tipsDataKey = 'cached_tips_data';
  static const Duration cacheDuration = Duration(hours: 1); // Cache 1 jam

  // Simpan user data ke cache
  static Future<void> cacheUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
    await prefs.setString(_lastCacheTimeKey, DateTime.now().toString());
  }

  // Get cached user data
  static Future<String?> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  // Simpan tasks data ke cache
  static Future<void> cacheTasksData(List<dynamic> tasksData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksDataKey, json.encode(tasksData));
    await prefs.setString(_lastCacheTimeKey, DateTime.now().toString());
  }

  // Get cached tasks data
  static Future<List<dynamic>?> getCachedTasksData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksDataString = prefs.getString(_tasksDataKey);
    if (tasksDataString != null) {
      return json.decode(tasksDataString);
    }
    return null;
  }

  // Cek apakah cache masih valid
  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastCacheTimeString = prefs.getString(_lastCacheTimeKey);

    if (lastCacheTimeString == null) return false;

    final lastCacheTime = DateTime.parse(lastCacheTimeString);
    final now = DateTime.now();

    return now.difference(lastCacheTime) < cacheDuration;
  }

  // Clear cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_tasksDataKey);
    await prefs.remove(_lastCacheTimeKey);
    await prefs.remove(_tipsDataKey);
  }

  static Future<void> clearTipsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tipsDataKey);
  }

  // Simpan tips data ke cache
  static Future<void> cacheTipsData(List<TipsItem> tipsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tipsJsonList = tipsData.map((tip) => tip.toJson()).toList();
      await prefs.setString(_tipsDataKey, json.encode(tipsJsonList));
      await prefs.setString(_lastCacheTimeKey, DateTime.now().toString());
      print('💾 Cache berhasil: ${tipsData.length} tips');
    } catch (e) {
      print('❌ Error caching tips: $e');
    }
  }

  // PERBAIKAN: Return List<TipsItem>
  static Future<List<TipsItem>?> getCachedTipsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tipsDataString = prefs.getString(_tipsDataKey);

      if (tipsDataString != null && tipsDataString.isNotEmpty) {
        final List<dynamic> tipsJsonList = json.decode(tipsDataString);
        final tips = tipsJsonList
            .map((json) => TipsItem.fromJson(json))
            .toList();
        print('📂 Loaded from cache: ${tips.length} tips');
        return tips;
      }
      print('📂 No cached tips found');
      return null;
    } catch (e) {
      print('❌ Error loading cached tips: $e');
      await clearTipsCache();
      return null;
    }
  }
}

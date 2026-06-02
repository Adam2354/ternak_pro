// lib/services/ternak_recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/HealtResponse.dart';
import '../models/TernakRecommendationResponse.dart';

class TernakRecommendationService {
  static const String _baseUrl = 'https://api.ternakpro.id/api/v1';
  static const Duration _timeout = Duration(seconds: 30);

  // ====== Helpers ======
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // null jika belum login
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ====== Health Check ======
  static Future<HealthResponse> healthCheck() async {
    final uri = Uri.parse('$_baseUrl/ai/rekomendasi-ternak/health');
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
      return HealthResponse.fromJson(jsonMap);
    } else {
      throw TernakApiException(
        message: 'Gagal memeriksa kesehatan service',
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }

  // ====== Get Recommendation ======
  /// Kirim data ke endpoint Laravel resmi:
  /// modal, lahan, waktu, pengalaman, dengan optional mode dan preset.
  static Future<TernakRecommendationResponse> getRecommendation({
    required num modal,
    required num lahan,
    required int waktu,
    required String pengalaman,
    String? mode,
    String? preset,
  }) async {
    final uri = Uri.parse('$_baseUrl/ai/rekomendasi-ternak');
    final payload = {
      'modal': modal,
      'lahan': lahan,
      'waktu': waktu,
      'pengalaman': pengalaman,
      if (mode != null && mode.isNotEmpty) 'mode': mode,
      if (preset != null && preset.isNotEmpty) 'preset': preset,
    };

    final res = await http
        .post(uri, headers: await _headers(), body: jsonEncode(payload))
        .timeout(_timeout);

    final bodyStr = res.body.isEmpty ? '{}' : res.body;
    final jsonMap = jsonDecode(bodyStr) as Map<String, dynamic>;

    // Laravel controller mengembalikan:
    // - 200: { success: true, message, data: { recommendations: [...] } }
    // - 422: { success: false, message, errors: {...} }
    // - 503/500: { success: false, message }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final success = jsonMap['success'] == true;
      if (!success) {
        throw TernakApiException(
          message:
              jsonMap['message']?.toString() ?? 'Gagal mendapatkan rekomendasi',
          statusCode: res.statusCode,
          body: res.body,
        );
      }
      return TernakRecommendationResponse.fromJson(jsonMap);
    } else if (res.statusCode == 422) {
      throw TernakValidationException(
        message: jsonMap['message']?.toString() ?? 'Validasi gagal',
        errors:
            (jsonMap['errors'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, List<String>.from(v as List)),
            ) ??
            {},
      );
    } else {
      throw TernakApiException(
        message:
            jsonMap['message']?.toString() ??
            'Terjadi kesalahan pada AI service',
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }
}

// ====== Exceptions ======
class TernakApiException implements Exception {
  final String message;
  final int statusCode;
  final String body;
  TernakApiException({
    required this.message,
    required this.statusCode,
    required this.body,
  });
  @override
  String toString() => 'TernakApiException($statusCode): $message\n$body';
}

class TernakValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;
  TernakValidationException({required this.message, required this.errors});
  @override
  String toString() => 'TernakValidationException: $message\n$errors';
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static const String baseUrl = 'https://hawariyyun.my.id/api/v1';
  
  String? authToken;
  final Completer<void> _tokenLoaded = Completer<void>();

  ChatService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('token');
      _tokenLoaded.complete();
    } catch (e) {
      _tokenLoaded.completeError(e);
    }
  }

  // Tunggu hingga token selesai dimuat
  Future<void> ensureTokenLoaded() async {
    await _tokenLoaded.future;
  }

  // Kirim pesan ke AI dengan timeout handling yang lebih baik
  Future<Map<String, dynamic>> sendMessage({
    required String userId,
    required String message,
    int? conversationId, // Tambahkan opsi cancel token
  }) async {
    await ensureTokenLoaded();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat/deepseek'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'user_id': userId,
          'message': message,
          'conversation_id': conversationId,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    }
  }

  // Mulai percakapan baru
  Future<Map<String, dynamic>> startNewConversation(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat/deepseek/new'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to start new conversation');
    }
  }

  // Dapatkan semua percakapan user
  Future<List<dynamic>> getConversations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/ai/conversations/deepseek'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  // Dapatkan percakapan spesifik
  Future<Map<String, dynamic>> getConversation(String userId, int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/ai/conversation/deepseek/$userId/$conversationId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  // Hapus percakapan
  Future<void> deleteConversation(String userId, int conversationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ai/conversation/deepseek/$userId/$conversationId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation');
    }
  }
}
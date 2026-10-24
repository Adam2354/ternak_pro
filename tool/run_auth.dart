import 'dart:convert';
import 'package:http/http.dart' as http;

// Edit baseUrl di bawah sesuai environment Anda (lokal atau staging)
const String baseUrl = 'https://api.ternakpro.id/api/v1';

Future<void> main() async {
  print('Testing REGISTER endpoint...');
  final registerPayload = {
    'name': 'Test User',
    'email': 'test.user+${DateTime.now().millisecondsSinceEpoch}@example.com',
    'password': 'P@ssw0rd123',
    'password_confirmation': 'P@ssw0rd123',
    'role_id': 3,
    'no_telepon': '081234567890',
  };

  try {
    final regResp = await http
        .post(
          Uri.parse('\$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registerPayload),
        )
        .timeout(const Duration(seconds: 30));

    print('REGISTER status: \\${regResp.statusCode}');
    print('REGISTER body:');
    print(regResp.body);
  } catch (e) {
    print('REGISTER error: $e');
  }

  print('\nTesting LOGIN endpoint...');
  final loginPayload = {
    // If you used the register test above, use same email/password
    'email_or_phone': registerPayload['email'],
    'password': registerPayload['password'],
  };

  try {
    final loginResp = await http
        .post(
          Uri.parse('\$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(loginPayload),
        )
        .timeout(const Duration(seconds: 30));

    print('LOGIN status: \\${loginResp.statusCode}');
    print('LOGIN body:');
    print(loginResp.body);
  } catch (e) {
    print('LOGIN error: $e');
  }
}

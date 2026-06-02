import 'dart:convert';

import 'package:ternak_pro/services/api_service.dart';

Future<void> main() async {
  final svc = ApiService();
  try {
    final res = await svc.getRekomendasiTernak(
      modal: 1000000,
      lahan: 500,
      waktu: 12,
      pengalaman: 'belum',
    );

    print('Result:\n${const JsonEncoder.withIndent('  ').convert(res)}');
  } catch (e) {
    print('Error calling getRekomendasiTernak: $e');
  }
}

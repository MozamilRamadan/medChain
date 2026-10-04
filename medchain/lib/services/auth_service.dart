import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/account.dart';

class AuthService {
  // غيّر هذا حسب طريقة تشغيل Flutter

  // Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // هاتف حقيقي Redmi Note 8:
  static const String baseUrl = 'http://192.168.0.157:3000/api';

  static Future<Map<String, dynamic>> login({
    required String nationalId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nationalId': nationalId,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Login failed',
      );
    }

    final account = Account.fromJson(data['user']);

    return {
      'token': data['token'],
      'account': account,
    };
  }



Future<Map<String, dynamic>> register({
  required String fullName,
  required String phone,
  required String nationalId,
  required String password,
  required String role,
  String? licenseNumber,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'fullName': fullName,
      'phone': phone,
      'nationalId': nationalId,
      'password': password,
      'roles': [role],
      if (licenseNumber != null && licenseNumber.isNotEmpty)
        'licenseNumber': licenseNumber,
    }),
  );

  print('REGISTER STATUS: ${response.statusCode}');
  print('REGISTER BODY: ${response.body}');

  if (response.body.trim().isEmpty) {
    throw Exception('Server returned empty response');
  }

  final data = jsonDecode(response.body);

  if (response.statusCode != 201) {
    throw Exception(
      data['message'] ?? 'Registration failed',
    );
  }

  if (data['success'] != true) {
    throw Exception(
      data['message'] ?? 'Registration failed',
    );
  }

  return data;
}


}
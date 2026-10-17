
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class AdminService {
  static Future<List<Map<String, dynamic>>> getUsers({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/admin/users'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.body.trim().isEmpty) {
      throw Exception('Server returned an empty response');
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Server returned an invalid response');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }

    if (response.statusCode != 200 || decoded['success'] != true) {
      throw Exception(
        decoded['message'] ?? 'Failed to load users',
      );
    }

    final users = decoded['users'];

    if (users is! List) {
      throw Exception('Invalid users data returned by server');
    }

    return users.map<Map<String, dynamic>>((user) {
      if (user is! Map) {
        throw Exception('Invalid user data returned by server');
      }

      return Map<String, dynamic>.from(user);
    }).toList();
  }

static Future<void> setAdminRole({
    required String token,
    required int userId,
    required bool enabled,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${AuthService.baseUrl}/admin/users/$userId/admin-role',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'enabled': enabled,
      }),
    );

    if (response.body.trim().isEmpty) {
      throw Exception('Server returned an empty response');
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Server returned an invalid response');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }

    if (response.statusCode != 200 || decoded['success'] != true) {
      throw Exception(
        decoded['message'] ?? 'Failed to update administrator role',
      );
    }
  }
static Future<void> removePatientProfile({
  required String token,
  required int userId,
}) {
  return _deleteAdminResource(
    token: token,
    path: '/admin/users/$userId/patient-profile',
  );
}

static Future<void> removeDoctorProfile({
  required String token,
  required int userId,
}) {
  return _deleteAdminResource(
    token: token,
    path: '/admin/users/$userId/doctor-profile',
  );
}

static Future<void> deleteUserAccount({
  required String token,
  required int userId,
}) {
  return _deleteAdminResource(
    token: token,
    path: '/admin/users/$userId',
  );
}


static Future<void> _deleteAdminResource({
  required String token,
  required String path,
}) async {
  final response = await http.delete(
    Uri.parse('${AuthService.baseUrl}$path'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.body.trim().isEmpty) {
    throw Exception('Server returned an empty response');
  }

  final dynamic decoded;

  try {
    decoded = jsonDecode(response.body);
  } on FormatException {
    throw Exception('Server returned an invalid response');
  }

  if (decoded is! Map<String, dynamic>) {
    throw Exception('Unexpected server response');
  }

  if (response.statusCode < 200 ||
      response.statusCode >= 300 ||
      decoded['success'] != true) {
    throw Exception(
      decoded['message'] ?? 'Failed to complete admin action',
    );
  }
}
}

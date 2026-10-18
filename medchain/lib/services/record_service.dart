import 'dart:convert';
import 'package:http/http.dart' as http;

class RecordService {
  static const String baseUrl =
      'http://192.168.0.157:3000/api';

  Future<Map<String, dynamic>> addRecord({
    required int patientId,
    required int doctorId,
    required String diagnosis,
    required String notes,
  }) async {
    final url = '$baseUrl/records';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'patientId': patientId,
        'doctorId': doctorId,
        'diagnosis': diagnosis,
        'notes': notes,
      }),
    );

    print('ADD RECORD STATUS: ${response.statusCode}');
    print('ADD RECORD BODY: ${response.body}');

    if (response.body.trim().isEmpty) {
      throw Exception('Server returned empty response');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(
        data['message'] ??
            'Failed to add record: ${response.statusCode}',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'Failed to add record',
      );
    }

    return data;
  }

  Future<List<dynamic>> getRecords(
    int patientId, {
    required String token,
  }) async {
    final url = '$baseUrl/records/$patientId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.body.trim().isEmpty) {
      throw Exception('Server returned empty response');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Failed to load records',
      );
    }

    if (data['success'] != true) {
      throw Exception('Failed to load records');
    }

    return data['records'] ?? [];
  }

  Future<List<dynamic>> getDoctorPatientRecords({
    required int doctorId,
    required int patientId,
  }) async {
    final url =
        '$baseUrl/records/doctor/$doctorId/patient/$patientId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
      },
    );

    print('DOCTOR RECORDS URL: $url');
    print('DOCTOR RECORDS STATUS: ${response.statusCode}');
    print('DOCTOR RECORDS BODY: ${response.body}');

    if (response.body.trim().isEmpty) {
      throw Exception('Server returned empty response');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ??
            'Failed to load doctor records',
      );
    }

    return data['records'] ?? [];
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class PermissionService {
  static const String baseUrl =
     'http://10.120.52.93:5000/api';

  // ============================================================
  // Doctor -> Request permission
  // ============================================================

  Future<void> requestPermission({
    required int patientId,
    required int doctorId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/permissions/request'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'patientId': patientId,
        'doctorId': doctorId,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 201) {
      throw Exception(
        data['message'] ?? 'Failed to request permission',
      );
    }
  }

  // ============================================================
  // Patient -> Get permission requests
  // ============================================================

  Future<List<dynamic>> getPatientPermissions(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/permissions/patient/$patientId',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Failed to load permissions',
      );
    }

    return data['permissions'] ?? [];
  }

  // ============================================================
  // Patient -> Approve / Reject permission
  // ============================================================

  Future<void> updatePermissionStatus({
    required int permissionId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/permissions/$permissionId/status',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ??
            'Failed to update permission',
      );
    }
  }

  // ============================================================
  // Doctor -> Get approved patients
  // ============================================================

  Future<List<dynamic>> getDoctorApprovedPatients(
    int doctorId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/permissions/doctor/$doctorId/approved',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ??
            'Failed to load approved patients',
      );
    }

    return data['patients'] ?? [];
  }

  // ============================================================
  // Common response decoder
  // ============================================================
  Map<String, dynamic> _decodeResponse( http.Response response, ) {
   print('STATUS: ${response.statusCode}'); 
   print('BODY: ${response.body}'); 
   if (response.body.trim().isEmpty) { 
    throw Exception( 'Server returned an empty response ' '(${response.statusCode})', ); 
    } try {
       final decoded = jsonDecode(response.body); 
       if (decoded is Map<String, dynamic>) { return decoded; 
       } throw Exception( 'Server returned an unexpected JSON format', );
        } on FormatException { throw Exception( 'Server returned invalid JSON ' '(${response.statusCode})', 
        );
         }
         }

  // ============================================================
  // revoke Permission
  // ============================================================
  Future<void> revokePermission({
      required int permissionId,
      required String token,
    }) async {
      final response = await http.put(
        Uri.parse('$baseUrl/permissions/$permissionId/revoke'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = _decodeResponse(response);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(
          data['message'] ?? 'Failed to revoke permission',
        );
      }
    }
}

import 'package:flutter/material.dart';
import 'package:medchen/Screens/doctor/doctor_patient_records_page.dart';

import '../../global/ProfileAvatar.dart';
import '../../services/permission_service.dart';

class DoctorPatientsPage extends StatefulWidget {
  final int doctorId;

  const DoctorPatientsPage({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorPatientsPage> createState() =>
      _DoctorPatientsPageState();
}

class _DoctorPatientsPageState
    extends State<DoctorPatientsPage> {
  final PermissionService _permissionService =
      PermissionService();

  List<dynamic> patients = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await _permissionService.getDoctorApprovedPatients(
        widget.doctorId,
      );

      if (!mounted) return;

      setState(() {
        patients = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void _openPatientRecords(dynamic patient) {
    final int patientId =
        int.parse(patient['PatientId'].toString());

    final String patientName =
        patient['FullName']?.toString() ??
            'Unknown Patient';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientRecordsPage(
          doctorId: widget.doctorId,
          patientId: patientId,
          patientName: patientName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (patients.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          return _buildPatientCard(patients[index]);
        },
      ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    final patientId = patient['PatientId'];

    final String patientName =
        patient['FullName']?.toString() ??
            'Unknown Patient';

    final String phone =
        patient['Phone']?.toString() ??
            'No phone number';

    final String? imagePath =
        patient['ProfileImagePath']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openPatientRecords(patient),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Patient profile image
              ProfileAvatar(
                imagePath: imagePath,
                radius:16 ,
              ),

              const SizedBox(width: 15),

              // Patient information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Patient ID: $patientId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Open patient records
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 17,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          Icon(
            Icons.people_outline,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Approved Patients',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patients who approve your access\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.error_outline,
            size: 70,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'Unable to Load Patients',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadPatients,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}

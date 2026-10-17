import 'package:flutter/material.dart';
import 'package:medchen/Screens/admin/admin_users_page.dart';

import 'package:medchen/Screens/doctor/add_record_page.dart';
import 'package:medchen/Screens/doctor/doctor_patients_page.dart';
import 'package:medchen/Screens/doctor/request_permission_page.dart';
import 'package:medchen/Screens/patient/medical_records_page.dart';
import 'package:medchen/Screens/patient/permission_requests_page.dart';
import 'package:medchen/global/app_button.dart';
import 'package:medchen/models/account.dart';

class DashboardPage extends StatelessWidget {
  final Account account;
  final String token;
  const DashboardPage({
    super.key,
    required this.account,
    this.token = ''
  });

  @override
  Widget build(BuildContext context) {
    final patientRole = account.roles.cast<AccountRole?>().firstWhere(
          (role) => role?.role == 'patient',
          orElse: () => null,
        );

    final doctorRole = account.roles.cast<AccountRole?>().firstWhere(
          (role) => role?.role == 'doctor',
          orElse: () => null,
        );
    final isAdmin = account.roles.any(
  (role) => role.role.toLowerCase() == 'admin',
);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedChain'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/icon_bg.jpg',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // Welcome
              Text(
                'Welcome, ${account.fullName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                account.roles
                    .map((role) => role.role)
                    .join(' / ')
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // Patient Section
              if (patientRole != null) ...[
                _buildSectionTitle(
                  context,
                  'Patient',
                  Icons.person_outline,
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: 'My Medical Records',
                  icon: Icons.folder_shared_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordsPage(
                          patientId: patientRole.roleId,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: 'Permission Requests',
                  icon: Icons.security_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PermissionRequestsPage(
                          patientId: patientRole.roleId,
                          token: token,
                        ),
                      ),
                    );
                  },
                ),
              ],

              // Doctor Section
              if (doctorRole != null) ...[
                if (patientRole != null) const SizedBox(height: 28),

                _buildSectionTitle(
                  context,
                  'Doctor',
                  Icons.medical_services_outlined,
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: 'Add Medical Record',
                  icon: Icons.add_circle_outline,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRecordPage(
                          doctorId: doctorRole.roleId,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: 'My Patients',
                  icon: Icons.people_outline,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorPatientsPage(
                          doctorId: doctorRole.roleId,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: 'Request Patient Access',
                  icon: Icons.lock_open_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestPermissionPage(
                          doctorId: doctorRole.roleId,
                        ),
                      ),
                    );
                  },
                ),
              ],
              
              if (isAdmin) ...[
                const SizedBox(height: 20),
                const Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Manage Users'),
                  subtitle: const Text('View registered users'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (token.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in again to access administration.'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUsersPage(token: token),
                      ),
                    );
                  },
                ),
              ],
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
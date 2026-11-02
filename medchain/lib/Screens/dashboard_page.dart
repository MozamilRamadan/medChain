
import 'package:flutter/material.dart';

import 'package:medchen/l10n/app_localizations.dart';
import 'package:medchen/Screens/admin/admin_users_page.dart';
import 'package:medchen/Screens/doctor/add_record_page.dart';
import 'package:medchen/Screens/doctor/doctor_patients_page.dart';
import 'package:medchen/Screens/doctor/request_permission_page.dart';
import 'package:medchen/Screens/patient/medical_records_page.dart';
import 'package:medchen/Screens/patient/permission_requests_page.dart';
import 'package:medchen/Screens/login/login_page.dart';
import 'package:medchen/Screens/profile_page.dart';
import 'package:medchen/global/app_button.dart';
import 'package:medchen/models/account.dart';

class DashboardPage extends StatelessWidget {
  final Account account;
  final String token;
  final Function(Locale)
  onLanguageChanged;

  const DashboardPage({
    super.key,
    required this.account,
    this.token = '',
    required this.onLanguageChanged
  });

 Future<void> _logout(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.logout),
      content: Text(l10n.confirmLogout),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(false);
          },
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(true);
          },
          child: Text(l10n.logout),
        ),
      ],
    ),
  );

  if (shouldLogout != true || !context.mounted) {
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => LoginPage(
        onLanguageChanged: onLanguageChanged,
      ),
    ),
    (route) => false,
  );

  }

  void _openProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfilePage(token: token),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        automaticallyImplyLeading: false,
       title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
           tooltip: l10n.profile,
            iconSize: 38,
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'profile') {
                _openProfile(context);
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Text(l10n.profile),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 10,),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.logout,
                      
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Image.asset(
                  'assets/images/icon_bg.jpg',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

             Text(
                l10n.welcome(account.fullName),
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

              if (patientRole != null) ...[
               _buildSectionTitle(
               context,
               l10n.patientSection,
               Icons.person_outline,
                 ),
                const SizedBox(height: 12),

                AppButton(
                 text: l10n.myMedicalRecords,
                  icon: Icons.folder_shared_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordsPage(
                          patientId: patientRole.roleId,
                          patientName: account.fullName,
                          token: token,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                AppButton(
                  text: l10n.permissionRequests,
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

              if (doctorRole != null) ...[
                if (patientRole != null) const SizedBox(height: 28),

               _buildSectionTitle(
               context,
               l10n.doctorSection,
               Icons.medical_services_outlined,
              ),
                const SizedBox(height: 12),

                AppButton(
                 text: l10n.addRecord,
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
                 text: l10n.myPatients,
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
                 text: l10n.requestPatientAccess,
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
                const SizedBox(height: 28),

                _buildSectionTitle(
                 context,
                 l10n.administrator,
                 Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 12),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  leading: const Icon(Icons.people),
                  title: Text(l10n.manageUsers),
                  subtitle: Text(
                  l10n.manageUsersDescription,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    if (token.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                         content: Text(
                         l10n.loginAgainAdmin,
                         ),
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

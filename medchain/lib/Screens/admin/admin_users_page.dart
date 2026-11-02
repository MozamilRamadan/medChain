import 'package:flutter/material.dart';
import 'package:medchen/l10n/app_localizations.dart';

import '../../services/admin_service.dart';

class AdminUsersPage extends StatefulWidget {
  final String token;

  const AdminUsersPage({
    super.key,
    required this.token,
  });

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  final TextEditingController _searchController =
      TextEditingController();

  final Set<int> _updatingUserIds = {};

  String _selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    _usersFuture = AdminService.getUsers(token: widget.token);
  }

  bool _isEnabled(dynamic value) {
    return value == true ||
        value == 1 ||
        value?.toString() == '1';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
           child: Text(
          AppLocalizations.of(context)!.cancel,
           ),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _changeAdminRole(
    Map<String, dynamic> user,
    bool currentlyAdmin,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = int.tryParse(
      user['UserId']?.toString() ?? '',
    );

    final fullName =
        user['FullName']?.toString() ?? 'this user';

    if (userId == null || userId <= 0) {
      _showMessage(l10n.invalidUserId);
      return;
    }

    final enable = !currentlyAdmin;

   final confirmed = await _confirmAction(
  title: enable
      ? l10n.grantAdminConfirmTitle
      : l10n.removeAdminConfirmTitle,
  message: enable
      ? l10n.grantAdminConfirmMessage(fullName)
      : l10n.removeAdminConfirmMessage(fullName),
  confirmText: enable
      ? l10n.grantAccess
      : l10n.removeAccess,
);
    if (!confirmed || !mounted) return;

    setState(() => _updatingUserIds.add(userId));

    try {
      await AdminService.setAdminRole(
        token: widget.token,
        userId: userId,
        enabled: enable,
      );

      if (!mounted) return;

      setState(_loadUsers);

     _showMessage(
  enable
      ? l10n.adminGrantedSuccess
      : l10n.adminRemovedSuccess,
);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingUserIds.remove(userId));
      }
    }
  }

  Future<void> _removeProfile(
    Map<String, dynamic> user, {
    required bool isPatient,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = int.tryParse(
      user['UserId']?.toString() ?? '',
    );

    if (userId == null || userId <= 0) {
     _showMessage(l10n.invalidUserId);
      return;
    }

    final fullName =
        user['FullName']?.toString() ?? 'this user';

   final profileName = isPatient
    ? l10n.patientProfile
    : l10n.doctorProfile;

    final confirmed = await _confirmAction(
  title: l10n.removeProfileTitle(profileName),
  message: l10n.removeProfileMessage(
    profileName,
    fullName,
  ),
  confirmText: l10n.removeProfile,
  destructive: true,
);
    if (!confirmed || !mounted) return;

    setState(() => _updatingUserIds.add(userId));

    try {
      if (isPatient) {
        await AdminService.removePatientProfile(
          token: widget.token,
          userId: userId,
        );
      } else {
        await AdminService.removeDoctorProfile(
          token: widget.token,
          userId: userId,
        );
      }

      if (!mounted) return;

      setState(_loadUsers);
    _showMessage(
  l10n.profileRemovedSuccess(profileName),
);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingUserIds.remove(userId));
      }
    }
  }

  Future<void> _deleteAccount(
    Map<String, dynamic> user,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = int.tryParse(
      user['UserId']?.toString() ?? '',
    );

    if (userId == null || userId <= 0) {
     _showMessage(l10n.invalidUserId);
      return;
    }

    final fullName =
        user['FullName']?.toString() ?? 'this user';

   final confirmed = await _confirmAction(
  title: l10n.deleteAccountTitle,
  message: l10n.deleteAccountMessage(fullName),
  confirmText: l10n.deleteAccount,
  destructive: true,
);

    if (!confirmed || !mounted) return;

    setState(() => _updatingUserIds.add(userId));

    try {
      await AdminService.deleteUserAccount(
        token: widget.token,
        userId: userId,
      );

      if (!mounted) return;

      setState(_loadUsers);
      _showMessage(l10n.accountDeletedSuccess);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingUserIds.remove(userId));
      }
    }
  }

 @override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Scaffold(
   appBar: AppBar(
  title: Text(l10n.adminUsersTitle),
  centerTitle: true,
  actions: [
    IconButton(
      tooltip: l10n.refreshUsers,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(_loadUsers);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(_loadUsers);
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final users = snapshot.data ?? [];

          final query =
              _searchController.text.trim().toLowerCase();

          final filteredUsers = users.where((user) {
            final name = (user['FullName'] ?? '')
                .toString()
                .toLowerCase();

            final nationalId = (user['NationalId'] ?? '')
                .toString()
                .toLowerCase();

            final phone = (user['Phone'] ?? '')
                .toString()
                .toLowerCase();

            final matchesSearch =
                name.contains(query) ||
                nationalId.contains(query) ||
                phone.contains(query);

            final isPatient = _isEnabled(user['IsPatient']);
            final isDoctor = _isEnabled(user['IsDoctor']);
            final isAdmin = _isEnabled(user['IsAdmin']);

            final matchesRole = switch (_selectedRole) {
              'Patient' => isPatient,
              'Doctor' => isDoctor,
              'Admin' => isAdmin,
              _ => true,
            };

            return matchesSearch && matchesRole;
          }).toList();

          if (users.isEmpty) {
           return Center(
           child: Text(l10n.noUsersFound),
           );
           }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12, 12, 12, 4,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                  hintText: l10n.searchUsersHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: l10n.clearSearch,
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12, 4, 12, 8,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                 decoration: InputDecoration(
                 labelText: l10n.filterByRole,
                 border: const OutlineInputBorder(),
                 ),
                  items: [
                  DropdownMenuItem(
                 value: 'All',
                 child: Text(l10n.allUsers),
                ),
                  DropdownMenuItem(
                 value: 'Patient',
                 child: Text(l10n.patients),
                  ),
                 DropdownMenuItem(
                 value: 'Doctor',
                 child: Text(l10n.doctors),
                 ),
                 DropdownMenuItem(
                 value: 'Admin',
                 child: Text(l10n.admins),
                ),
                ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                 l10n.showingUsers(
                 filteredUsers.length.toString(),
                 users.length.toString(),
                 ),
),
                ),
              ),
             Expanded(
  child: filteredUsers.isEmpty
      ? Center(
          child: Text(
            AppLocalizations.of(context)!.noMatchingUsers,
          ),
        )
      : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];

                          final isPatient =
                              _isEnabled(user['IsPatient']);
                          final isDoctor =
                              _isEnabled(user['IsDoctor']);
                          final isAdmin =
                              _isEnabled(user['IsAdmin']);

                          final userId = int.tryParse(
                            user['UserId']?.toString() ?? '',
                          );

                          final isUpdating = userId != null &&
                              _updatingUserIds.contains(userId);
final l10n = AppLocalizations.of(context)!;

final roles = <String>[
  if (isPatient) l10n.patientProfile,
  if (isDoctor) l10n.doctorProfile,
  if (isAdmin) l10n.administrator,
];

                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      child: Icon(
                                        isAdmin
                                            ? Icons.admin_panel_settings
                                            : Icons.person_outline,
                                      ),
                                    ),
                                    title: Text(
                                      user['FullName']?.toString() ??
                                      AppLocalizations.of(context)!.unknownUser,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                       Text(
  l10n.userIdLabel(
    (user['UserId'] ?? '-').toString(),
  ),
),
Text(
  l10n.nationalIdLabel(
    (user['NationalId'] ?? '-').toString(),
  ),
),
Text(
  l10n.phoneLabel(
    (user['Phone'] ?? '-').toString(),
  ),
),
Text(
  l10n.rolesLabel(
    roles.isEmpty ? l10n.none : roles.join(', '),
  ),
),
                                      ],
                                    ),
                                  ),
                                  const Divider(),

                                  // Grant or remove administrator access.
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          isUpdating || userId == null
                                              ? null
                                              : () => _changeAdminRole(
                                                    user,
                                                    isAdmin,
                                                  ),
                                      icon: isUpdating
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
                                              isAdmin
                                                  ? Icons
                                                      .admin_panel_settings_outlined
                                                  : Icons
                                                      .admin_panel_settings,
                                            ),
                                     label: Text(
  isUpdating
      ? AppLocalizations.of(context)!.processing
      : isAdmin
          ? AppLocalizations.of(context)!.removeAdminAccess
          : AppLocalizations.of(context)!.grantAdminAccess,
),
                                    ),
                                  ),

                                 // Remove patient profile only.
if (isPatient)
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: isUpdating || userId == null
          ? null
          : () => _removeProfile(
                user,
                isPatient: true,
              ),
      icon: const Icon(Icons.person_remove),
      label: Text(
        '${l10n.removeProfile} ${l10n.patientProfile}',
      ),
    ),
  ),

// Remove doctor profile only.
if (isDoctor)
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: isUpdating || userId == null
          ? null
          : () => _removeProfile(
                user,
                isPatient: false,
              ),
      icon: const Icon(
        Icons.medical_services_outlined,
      ),
      label: Text(
        '${l10n.removeProfile} ${l10n.doctorProfile}',
      ),
    ),
  ),

// Delete the entire user account.
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: isUpdating || userId == null
        ? null
        : () => _deleteAccount(user),
    icon: const Icon(Icons.delete_forever),
    label: Text(l10n.deleteAccount),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.red,
    ),
  ),
),
                                  // Delete the entire user account.
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          isUpdating || userId == null
                                              ? null
                                              : () => _deleteAccount(user),
                                      icon: const Icon(
                                        Icons.delete_forever,
                                      ),
                                      label: const Text(
                                        'Delete Account',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
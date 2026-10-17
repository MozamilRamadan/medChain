import 'package:flutter/material.dart';

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
            child: const Text('Cancel'),
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
    final userId = int.tryParse(
      user['UserId']?.toString() ?? '',
    );

    final fullName =
        user['FullName']?.toString() ?? 'this user';

    if (userId == null || userId <= 0) {
      _showMessage('Invalid user ID');
      return;
    }

    final enable = !currentlyAdmin;

    final confirmed = await _confirmAction(
      title: enable
          ? 'Grant administrator access?'
          : 'Remove administrator access?',
      message: enable
          ? 'Grant $fullName permission to manage users?'
          : 'Remove administrator permissions from $fullName?',
      confirmText: enable ? 'Grant access' : 'Remove access',
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
            ? 'Administrator access granted successfully'
            : 'Administrator access removed successfully',
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
    final userId = int.tryParse(
      user['UserId']?.toString() ?? '',
    );

    if (userId == null || userId <= 0) {
      _showMessage('Invalid user ID');
      return;
    }

    final fullName =
        user['FullName']?.toString() ?? 'this user';

    final profileName = isPatient ? 'Patient' : 'Doctor';

    final confirmed = await _confirmAction(
      title: 'Remove $profileName Profile?',
      message:
          'Remove the $profileName profile for $fullName? '
          'The user account will remain.',
      confirmText: 'Remove Profile',
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
      _showMessage('$profileName profile removed successfully');
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
    final userId = int.tryParse(
      user['UserId']?.toString() ?? '',
    );

    if (userId == null || userId <= 0) {
      _showMessage('Invalid user ID');
      return;
    }

    final fullName =
        user['FullName']?.toString() ?? 'this user';

    final confirmed = await _confirmAction(
      title: 'Delete Account Permanently?',
      message:
          'Delete the entire account belonging to $fullName, '
          'including associated SQL database records? '
          'This action cannot be undone. Copies already stored '
          'on the blockchain or IPFS will remain.',
      confirmText: 'Delete Account',
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
      _showMessage('Account deleted successfully');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh users',
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
                      child: const Text('Retry'),
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
            return const Center(
              child: Text('No users found.'),
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
                    hintText:
                        'Search name, national ID, or phone',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Clear search',
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
                  decoration: const InputDecoration(
                    labelText: 'Filter by role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All users'),
                    ),
                    DropdownMenuItem(
                      value: 'Patient',
                      child: Text('Patients'),
                    ),
                    DropdownMenuItem(
                      value: 'Doctor',
                      child: Text('Doctors'),
                    ),
                    DropdownMenuItem(
                      value: 'Admin',
                      child: Text('Admins'),
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
                    'Showing ${filteredUsers.length} '
                    'of ${users.length} users',
                  ),
                ),
              ),
              Expanded(
                child: filteredUsers.isEmpty
                    ? const Center(
                        child: Text('No matching users found.'),
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

                          final roles = <String>[
                            if (isPatient) 'Patient',
                            if (isDoctor) 'Doctor',
                            if (isAdmin) 'Admin',
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
                                          'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'User ID: '
                                          '${user['UserId'] ?? '-'}',
                                        ),
                                        Text(
                                          'National ID: '
                                          '${user['NationalId'] ?? '-'}',
                                        ),
                                        Text(
                                          'Phone: '
                                          '${user['Phone'] ?? '-'}',
                                        ),
                                        Text(
                                          'Roles: '
                                          '${roles.isEmpty ? 'None' : roles.join(', ')}',
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
                                            ? 'Processing...'
                                            : isAdmin
                                                ? 'Remove Admin Access'
                                                : 'Grant Admin Access',
                                      ),
                                    ),
                                  ),

                                  // Remove patient profile only.
                                  if (isPatient)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            isUpdating || userId == null
                                                ? null
                                                : () => _removeProfile(
                                                      user,
                                                      isPatient: true,
                                                    ),
                                        icon: const Icon(
                                          Icons.person_remove,
                                        ),
                                        label: const Text(
                                          'Remove Patient Profile',
                                        ),
                                      ),
                                    ),

                                  // Remove doctor profile only.
                                  if (isDoctor)
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            isUpdating || userId == null
                                                ? null
                                                : () => _removeProfile(
                                                      user,
                                                      isPatient: false,
                                                    ),
                                        icon: const Icon(
                                          Icons.medical_services_outlined,
                                        ),
                                        label: const Text(
                                          'Remove Doctor Profile',
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
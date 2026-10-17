import 'package:flutter/material.dart';

import '../../services/permission_service.dart';

class PermissionRequestsPage extends StatefulWidget {
  final int patientId;
  final String token;

  const PermissionRequestsPage({
    super.key,
    required this.patientId,
    required this.token,
  });

  @override
  State<PermissionRequestsPage> createState() =>
      _PermissionRequestsPageState();
}

class _PermissionRequestsPageState
    extends State<PermissionRequestsPage> {
  final PermissionService _permissionService =
      PermissionService();

  bool isLoading = true;
  String? errorMessage;

  List<dynamic> permissions = [];

  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  Future<void> loadPermissions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await _permissionService.getPatientPermissions(
        widget.patientId,
      );

      if (!mounted) return;

      setState(() {
        permissions = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        isLoading = false;
      });
    }
  }

  Future<void> updatePermission(
    int permissionId,
    String status,
  ) async {
    try {
      await _permissionService.updatePermissionStatus(
        permissionId: permissionId,
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Permission approved'
                : 'Permission rejected',
          ),
        ),
      );

      await loadPermissions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }
  
  
  Future<void> revokePermission(int permissionId) async {
    try {
      await PermissionService().revokePermission(
        permissionId: permissionId,
        token: widget.token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor permission revoked successfully'),
        ),
      );

      await loadPermissions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;

      case 'rejected':
        return Icons.cancel_outlined;

      default:
        return Icons.access_time;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Permission Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadPermissions,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
      return _buildError();
    }

    if (permissions.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: loadPermissions,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          return _buildPermissionCard(
            permissions[index],
          );
        },
      ),
    );
  }

  Widget _buildPermissionCard(dynamic permission) {
    final int permissionId =
        permission['PermissionId'] as int;

    final String doctorName =
        permission['DoctorName']?.toString() ??
            'Unknown Doctor';

    final String specialization =
        permission['Specialization']?.toString() ??
            'Unknown Specialization';

    final String licenseNumber =
        permission['LicenseNumber']?.toString() ??
            'N/A';

    final String status =
        permission['Status']?.toString() ??
            'pending';

    final Color statusColor =
        _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Doctor header
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7F7),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Image.asset(
                    'assets/images/icon_bg.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        specialization,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _buildStatusBadge(
                  status,
                  statusColor,
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(height: 1),

            const SizedBox(height: 16),

            // Doctor information
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.badge_outlined,
                    title: 'License',
                    value: licenseNumber,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Status',
                    value: _getStatusText(status),
                    valueColor: statusColor,
                  ),
                ),
              ],
            ),

            // Actions only for pending
            if (status.toLowerCase() ==
                'pending') ...[
              const SizedBox(height: 20),

              const Text(
                'This doctor is requesting access to your medical records.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        updatePermission(
                          permissionId,
                          'approved',
                        );
                      },
                      icon: const Icon(
                        Icons.check,
                        size: 20,
                      ),
                      label: const Text(
                        'Approve',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        updatePermission(
                          permissionId,
                          'rejected',
                        );
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                      label: const Text(
                        'Reject',
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            
            if (status.toLowerCase() == 'approved')
            
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Revoke Permission'),
                      content: const Text(
                        'Are you sure you want to revoke this doctor’s access?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, true),
                          child: const Text('Revoke'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await revokePermission(
                      int.parse(permission['PermissionId'].toString()),
                    );
                  }
                },
                icon: const Icon(Icons.block),
                label: const Text('Revoke Permission'),
              ),
            
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 15,
            color: color,
          ),

          const SizedBox(width: 5),

          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: loadPermissions,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),

          Icon(
            Icons.verified_user_outlined,
            size: 75,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'No Permission Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Text(
                'Doctors who request access to your medical records will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 65,
              color: Colors.red.shade300,
            ),

            const SizedBox(height: 15),

            const Text(
              'Could not load permission requests',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loadPermissions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
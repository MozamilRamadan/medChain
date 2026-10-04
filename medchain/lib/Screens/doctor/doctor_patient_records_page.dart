import 'package:flutter/material.dart';

import '../../services/record_service.dart';

class DoctorPatientRecordsPage extends StatefulWidget {
  final int doctorId;
  final int patientId;
  final String patientName;

  const DoctorPatientRecordsPage({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPatientRecordsPage> createState() =>
      _DoctorPatientRecordsPageState();
}

class _DoctorPatientRecordsPageState
    extends State<DoctorPatientRecordsPage> {
  final RecordService _recordService = RecordService();

  List<dynamic> records = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await _recordService.getDoctorPatientRecords(
        doctorId: widget.doctorId,
        patientId: widget.patientId,
      );

      if (!mounted) return;

      setState(() {
        records = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patientName,
          overflow: TextOverflow.ellipsis,
        ),
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

    if (records.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        itemCount: records.length,
        itemBuilder: (context, index) {
          return _buildRecordCard(
            records[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
    dynamic record,
    int index,
  ) {
    final diagnosis =
        record['Diagnosis'] ?? 'No diagnosis';

    final notes =
        record['Notes'] ?? 'No medical notes';

    final doctorName =
        record['DoctorName'] ?? 'Unknown doctor';

    final specialization =
        record['Specialization'] ?? '';

    final ipfsCID =
        record['IpfsCID'] ?? 'Not available';

    final blockchainId =
        record['BlockchainRecordId'] ?? 'Not available';

    final createdAt =
        record['CreatedAt'] ?? record['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(14),
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    Icons.medical_information_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Record ${index + 1}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      if (specialization
                          .toString()
                          .isNotEmpty)
                        Text(
                          specialization,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 14),

            // Diagnosis
            _buildInfoSection(
              icon: Icons.local_hospital_outlined,
              title: 'Diagnosis',
              value: diagnosis.toString(),
            ),

            const SizedBox(height: 16),

            // Notes
            _buildInfoSection(
              icon: Icons.notes_outlined,
              title: 'Medical Notes',
              value: notes.toString(),
            ),

            const SizedBox(height: 16),

            // Date
            if (createdAt != null)
              _buildInfoSection(
                icon: Icons.calendar_today_outlined,
                title: 'Date',
                value: _formatDate(createdAt),
              ),

            const SizedBox(height: 16),

            // IPFS
            _buildTechnicalInfo(
              title: 'IPFS CID',
              value: ipfsCID.toString(),
              icon: Icons.cloud_outlined,
            ),

            const SizedBox(height: 10),

            // Blockchain
            _buildTechnicalInfo(
              title: 'Blockchain Record',
              value: blockchainId.toString(),
              icon: Icons.link_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalInfo({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),

          Icon(
            Icons.folder_open_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            'No Medical Records',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'No medical records are available\n'
            'for this patient.',
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
      onRefresh: _loadRecords,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
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
            'Unable to Load Records',
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
              onPressed: _loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    try {
      final date = DateTime.parse(
        value.toString(),
      );

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }
}
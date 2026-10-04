import 'package:flutter/material.dart';
import 'package:medchen/services/record_service.dart';

class MedicalRecordsPage extends StatefulWidget {
  final int patientId;

  const MedicalRecordsPage({
    super.key,
    required this.patientId,
  });

  @override
  State<MedicalRecordsPage> createState() =>
      _MedicalRecordsPageState();
}

class _MedicalRecordsPageState
    extends State<MedicalRecordsPage> {
  List<dynamic> records = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final RecordService _recordService = RecordService();

      final result = await _recordService.getRecords(widget.patientId,);

      if (!mounted) return;

      setState(() {
        records = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String formatDate(dynamic value) {
    try {
      final date = DateTime.parse(
        value.toString(),
      ).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}  '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Unknown date';
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
          'Medical Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadRecords,
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

    if (records.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: loadRecords,
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
          return _buildRecordCard(records[index]);
        },
      ),
    );
  }

  Widget _buildRecordCard(
    dynamic record,
  ) {
    final int recordId =
        record['RecordId'] as int;

    final String diagnosis =
        record['Diagnosis']?.toString() ??
            'Unknown diagnosis';

    final String doctorName =
        record['DoctorName']?.toString() ??
            'Unknown doctor';

    final String specialization =
        record['Specialization']?.toString() ??
            '';

    final String createdAt =
        formatDate(record['CreatedAt']);

    final String notes =
        record['Notes']?.toString() ?? '';

    final String ipfsCID =
        record['IpfsCID']?.toString() ?? 'Unknown';

    final String blockchainId =
        record['BlockchainRecordId']?.toString() ??
            'Unknown';

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

      child: Column(
        children: [
          // ─────────────────────────────
          // Header
          // ─────────────────────────────

          Padding(
            padding: const EdgeInsets.all(18),

            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(15),
                    color: const Color(0xFFF0F7F7),
                  ),

                  child: Image.asset(
                    'assets/images/icon_bg.jpg',
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
                        'Medical Record',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '#$recordId',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: const Text(
                    'Recorded',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
          ),

          // ─────────────────────────────
          // Diagnosis
          // ─────────────────────────────

          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              10,
            ),

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Diagnosis',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    diagnosis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─────────────────────────────
          // Doctor + Date
          // ─────────────────────────────

          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              6,
              18,
              10,
            ),

            child: Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.person_outline,
                    title: 'Doctor',
                    value: doctorName,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _infoItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Date',
                    value: createdAt,
                  ),
                ),
              ],
            ),
          ),

          if (specialization.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                10,
              ),
              child: _infoItem(
                icon: Icons.medical_information_outlined,
                title: 'Specialization',
                value: specialization,
              ),
            ),

          // ─────────────────────────────
          // Notes preview
          // ─────────────────────────────

          if (notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                4,
                18,
                14,
              ),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Medical Notes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─────────────────────────────
          // View Details
          // ─────────────────────────────

          InkWell(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),

            onTap: () {
              _showRecordDetails(
                recordId: recordId,
                patientId:
                    record['PatientId'] as int,
                doctorId:
                    record['DoctorId'] as int,
                doctorName: doctorName,
                specialization: specialization,
                diagnosis: diagnosis,
                notes: notes,
                createdAt: createdAt,
                ipfsCID: ipfsCID,
                blockchainId: blockchainId,
              );
            },

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),

              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFC),
                borderRadius:
                    const BorderRadius.only(
                  bottomLeft:
                      Radius.circular(20),
                  bottomRight:
                      Radius.circular(20),
                ),
              ),

              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails({
    required int recordId,
    required int patientId,
    required int doctorId,
    required String doctorName,
    required String specialization,
    required String diagnosis,
    required String notes,
    required String createdAt,
    required String ipfsCID,
    required String blockchainId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.78,

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icon_bg.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Medical Record #$recordId',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _detailSection(
                            'Patient',
                            'Patient ID: $patientId',
                          ),

                          _detailSection(
                            'Doctor',
                            '$doctorName\n'
                            'Doctor ID: $doctorId'
                            '${specialization.isNotEmpty ? '\n$specialization' : ''}',
                          ),

                          _detailSection(
                            'Diagnosis',
                            diagnosis,
                          ),

                          if (notes.isNotEmpty)
                            _detailSection(
                              'Medical Notes',
                              notes,
                            ),

                          _detailSection(
                            'Created',
                            createdAt,
                          ),

                          _detailSection(
                            'IPFS CID',
                            ipfsCID,
                          ),

                          _detailSection(
                            'Blockchain Record',
                            blockchainId,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailSection(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FA),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: loadRecords,

      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        children: [
          const SizedBox(height: 170),

          Icon(
            Icons.folder_open_outlined,
            size: 75,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'No Medical Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'Your medical records will appear here.',
              style: TextStyle(
                color: Colors.grey.shade600,
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
              'Could not load medical records',
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
              onPressed: loadRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
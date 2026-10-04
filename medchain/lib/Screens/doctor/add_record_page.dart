import 'package:flutter/material.dart';

import '../../global/app_button.dart';
import '../../global/app_text_feild.dart';
import '../../services/record_service.dart';

class AddRecordPage extends StatefulWidget {
  final int doctorId;

  const AddRecordPage({
    super.key,
    required this.doctorId,
  });

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();

  final patientIdController = TextEditingController();
  final diagnosisController = TextEditingController();
  final notesController = TextEditingController();

  final RecordService _recordService = RecordService();

  bool isLoading = false;

  @override
  void dispose() {
    patientIdController.dispose();
    diagnosisController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> addRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final patientId = int.tryParse(
      patientIdController.text.trim(),
    );

    if (patientId == null) {
      _showMessage('Patient ID must be a number');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _recordService.addRecord(
        patientId: patientId,
        doctorId: widget.doctorId,
        diagnosis: diagnosisController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      _showMessage(
        'Medical record added successfully',
      );

      patientIdController.clear();
      diagnosisController.clear();
      notesController.clear();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Record'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/icon_bg.jpg',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Add Medical Record',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter the patient medical information',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 30),

                // Patient ID
                AppTextField(
                  controller: patientIdController,
                  hintText: 'Patient ID',
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter Patient ID';
                    }

                    if (int.tryParse(value.trim()) == null) {
                      return 'Patient ID must be a number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Diagnosis
                AppTextField(
                  controller: diagnosisController,
                  hintText: 'Diagnosis',
                  icon: Icons.local_hospital_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter diagnosis';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Notes
                AppTextField(
                  controller: notesController,
                  hintText: 'Medical Notes',
                  icon: Icons.notes_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter medical notes';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  AppButton(
                    text: 'Add Medical Record',
                    icon: Icons.add_circle_outline,
                    onPressed: addRecord,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
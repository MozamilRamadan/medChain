import 'package:flutter/material.dart';

import '../../global/app_button.dart';
import '../../global/app_text_feild.dart';
import '../../services/permission_service.dart';

class RequestPermissionPage extends StatefulWidget {
  final int doctorId;

  const RequestPermissionPage({
    super.key,
    required this.doctorId,
  });

  @override
  State<RequestPermissionPage> createState() =>
      _RequestPermissionPageState();
}

class _RequestPermissionPageState
    extends State<RequestPermissionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController patientIdController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    patientIdController.dispose();
    super.dispose();
  }

  Future<void> requestPermission() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int? patientId =
        int.tryParse(patientIdController.text.trim());

    if (patientId == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final PermissionService _permissionService = PermissionService();

      await _permissionService.requestPermission(
        patientId: patientId,
        doctorId: widget.doctorId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Permission request sent successfully',
          ),
        ),
      );

      patientIdController.clear();
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Patient Access',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 25),

                Image.asset(
                  'assets/images/icon_bg.jpg',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Request Patient Access',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter the Patient ID to send '
                  'a request to access their '
                  'medical records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                AppTextField(
                  controller: patientIdController,
                  hintText: 'Patient ID',
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter Patient ID';
                    }

                    if (int.tryParse(
                          value.trim(),
                        ) ==
                        null) {
                      return 'Patient ID must be a number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  AppButton(
                    text: 'Send Request',
                    icon: Icons.send,
                    onPressed: requestPermission,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:medchen/Screens/dashboard_page.dart';
import 'package:medchen/global/app_button.dart';
import 'package:medchen/global/app_text_feild.dart';
import 'package:medchen/models/account.dart';
import 'package:medchen/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  final bool isDoctor;

  const SignupPage({
    super.key,
    required this.isDoctor,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _licenseNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });
final AuthService _authService = AuthService();
    try {
      await _authService.register(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        nationalId: _idController.text.trim(),
        password: _passwordController.text,
        role: widget.isDoctor ? 'doctor' : 'patient',
        licenseNumber: _licenseNumberController.text.trim(),
      );

      final loginResult = await AuthService.login(
        nationalId: _idController.text.trim(),
        password: _passwordController.text,
      );

      final Account account = loginResult['account'];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            account: account, onLanguageChanged: (Locale p1) {  },
          ),
        ),
      );
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
        title: Text(
          widget.isDoctor
              ? 'Doctor Account'
              : 'Patient Account',
        ),
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
                Image.asset(
                  'assets/images/icon_bg.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                Text(
                  widget.isDoctor
                      ? 'Create Doctor Account'
                      : 'Create Patient Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter your information',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                AppTextField(
                  hintText: 'Full Name',
                  icon: Icons.person,
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }

                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AppTextField(
                  hintText: 'Phone Number',
                  icon: Icons.phone,
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }

                    if (!RegExp(r'^[0-9]{10,15}$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AppTextField(
                  hintText: 'ID Number',
                  icon: Icons.badge,
                  controller: _idController,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your ID number';
                    }

                    if (value.trim().length < 4) {
                      return 'ID number is too short';
                    }

                    return null;
                  },
                ),

                if (widget.isDoctor) ...[
                const SizedBox(height: 16),

                AppTextField(
                    controller: _licenseNumberController,
                    hintText: 'License Number',
                    icon: Icons.badge_outlined,
                  ),
                ],
                
                const SizedBox(height: 15),
                AppTextField(
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AppTextField(
                  hintText: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                AppButton(
                  text: isLoading
                      ? 'Creating Account...'
                      : 'Create Account',
                  icon: Icons.person_add,
                  onPressed: isLoading ? () {} : _signup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
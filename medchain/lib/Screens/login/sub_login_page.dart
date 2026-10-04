import 'package:flutter/material.dart';

import 'package:medchen/Screens/dashboard_page.dart';
import 'package:medchen/Screens/login/SignupPage.dart';
import 'package:medchen/models/account.dart';
import 'package:medchen/services/auth_service.dart';

import '../../global/app_button.dart';
import '../../global/app_text_feild.dart';

class SubLoginPage extends StatefulWidget {
  final bool isDoctor;

  const SubLoginPage({
    super.key,
    required this.isDoctor,
  });

  @override
  State<SubLoginPage> createState() => _SubLoginPageState();
}

class _SubLoginPageState extends State<SubLoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await AuthService.login(
        nationalId: idController.text.trim(),
        password: passwordController.text,
      );

      final Account account = result['account'];

      final requiredRole =
          widget.isDoctor ? 'doctor' : 'patient';

      final hasRequiredRole = account.roles.any(
        (role) =>
            role.role.toLowerCase() == requiredRole,
      );

      if (!hasRequiredRole) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This account is not registered as a $requiredRole',
            ),
          ),
        );

        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            account: account,
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
    final role =
        widget.isDoctor ? 'Doctor' : 'Patient';

    return Scaffold(
      appBar: AppBar(
        title: Text('Login as $role'),
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
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                          0.20,
                  child: Image.asset(
                    'assets/images/icon_bg.jpg',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Login as $role',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
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
                  controller: idController,
                  hintText: 'ID Number',
                  icon: Icons.badge,
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

                const SizedBox(height: 15),

                AppTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
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

                const SizedBox(height: 25),

                AppButton(
                  text: isLoading
                      ? 'Logging in...'
                      : 'Login',
                  icon: Icons.login,
                  onPressed: isLoading ? () {} : _login,
                ),

                const SizedBox(height: 15),

                InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignupPage(
                                isDoctor:
                                    widget.isDoctor,
                              ),
                            ),
                          );
                        },
                  child: const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
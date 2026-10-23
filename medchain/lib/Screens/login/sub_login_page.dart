import 'package:flutter/material.dart';

import 'package:medchen/Screens/dashboard_page.dart';
import 'package:medchen/Screens/login/SignupPage.dart';
import 'package:medchen/Screens/login/forgot_password_page.dart';
import 'package:medchen/models/account.dart';
import 'package:medchen/services/auth_service.dart';
import 'package:medchen/l10n/app_localizations.dart';

import '../../global/app_button.dart';
import '../../global/app_text_feild.dart';

class SubLoginPage extends StatefulWidget {
  final bool isDoctor;
  final Function(Locale) onLanguageChanged;


  const SubLoginPage({
    super.key,
    required this.isDoctor,
    required this.onLanguageChanged,
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
      final String token = result['token'];

      debugPrint(
        'USER ROLES: ${account.roles.map((role) => role.role).toList()}',
      );

      final roles = account.roles
          .map((role) => role.role.toLowerCase())
          .toSet();

      final requiredRole = widget.isDoctor ? 'doctor' : 'patient';

      final hasRequiredRole = roles.contains(requiredRole);

      if (!hasRequiredRole) {
        if (!mounted) return;

        final localizations = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.accountWrongRole(
                widget.isDoctor
                    ? localizations.doctorRole
                    : localizations.patientRole,
              ),
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
            token: token, 
            onLanguageChanged: widget.onLanguageChanged,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
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
    final localizations = AppLocalizations.of(context)!;

   final roleTitle = widget.isDoctor
    ? localizations.loginAsDoctor
    : localizations.loginAsPatient;

    final pageTitle = widget.isDoctor
        ? localizations.loginAsDoctor
        : localizations.loginAsPatient;

    return Scaffold(
      appBar: AppBar(
        title: Text(roleTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height * 0.20,
                  child: Image.asset(
                    'assets/images/icon_bg.jpg',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  pageTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  localizations.enterInformation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                AppTextField(
                  controller: idController,
                  hintText: localizations.idNumber,
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localizations.pleaseEnterId;
                    }

                    if (value.trim().length < 4) {
                      return localizations.idTooShort;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                AppTextField(
                  controller: passwordController,
                  hintText: localizations.password,
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseEnterPassword;
                    }

                    if (value.length < 6) {
                      return localizations.passwordTooShort;
                    }

                    return null;
                  },
                ),

              // زر نسيت كلمة المرور
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: isLoading
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ForgotPasswordPage(
                  isDoctor: widget.isDoctor,
                ),
              ),
            );
          },
    child: Text(
      localizations.forgotPassword,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

const SizedBox(height: 10),

// زر تسجيل الدخول
        AppButton(
         text: isLoading
        ? localizations.loggingIn
        : localizations.login,
        icon: Icons.login,
        onPressed: isLoading ? () {} : _login,
),

const SizedBox(height: 15),

                const SizedBox(height: 15),

                InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignupPage(
                                isDoctor: widget.isDoctor,
                              ),
                            ),
                          );
                        },
                  child: Center(
                    child: Text(
                      localizations.createAccount,
                      style: const TextStyle(
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
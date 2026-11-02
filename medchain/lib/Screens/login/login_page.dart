import 'package:flutter/material.dart';
import 'package:medchen/Screens/login/sub_login_page.dart';
import '../../global/app_button.dart';
import 'package:medchen/l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  final Function(Locale) onLanguageChanged;

  const LoginPage({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية التطبيق
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // طبقة تعتيم الخلفية
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // زر تغيير اللغة أعلى الشاشة
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PopupMenuButton<String>(
                      tooltip: localizations.selectLanguage,
                      icon: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 30,
                      ),
                      color: Colors.white,
                      onSelected: (language) {
                        onLanguageChanged(Locale(language));
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'ar',
                          child: Row(
                            children: [
                              const Text('🇸🇩'),
                              const SizedBox(width: 10),
                              Text(localizations.arabic),
                              if (currentLanguage == 'ar') ...[
                                const Spacer(),
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'en',
                          child: Row(
                            children: [
                              const Text('🇬🇧'),
                              const SizedBox(width: 10),
                              Text(localizations.english),
                              if (currentLanguage == 'en') ...[
                                const Spacer(),
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // أزرار تسجيل الدخول
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 120),

                          AppButton(
                            text: localizations.patientLogin,
                            icon: Icons.login,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubLoginPage(
                                    isDoctor: false,
                                    onLanguageChanged: onLanguageChanged,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 15),

                          AppButton(
                            text: localizations.doctorLogin,
                            icon: Icons.login,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubLoginPage(
                                    isDoctor: true,
                                    onLanguageChanged: onLanguageChanged,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
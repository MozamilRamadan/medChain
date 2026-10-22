import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medchen/Screens/login/login_page.dart';
import 'package:medchen/l10n/app_localizations.dart';

void main() {
  runApp(const MedChainApp());
}

class MedChainApp extends StatefulWidget {
  const MedChainApp({super.key});

  @override
  State<MedChainApp> createState() => _MedChainAppState();
}

class _MedChainAppState extends State<MedChainApp> {
  Locale _locale = const Locale('ar');

  void changeLanguage(Locale locale) {
    if (_locale.languageCode == locale.languageCode) {
      return;
    }

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedChain',
      locale: _locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: LoginPage(
        onLanguageChanged: changeLanguage,
      ),
    );
  }
}
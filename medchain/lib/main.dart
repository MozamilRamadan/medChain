import 'package:flutter/material.dart';
import 'package:medchen/Screens/login/login_page.dart';

void main() {
  runApp(const MedChainApp());
}

class MedChainApp extends StatelessWidget {
  const MedChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedChain',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:  LoginPage(),
    );
  }
}
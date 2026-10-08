import 'package:flutter/material.dart';
import 'package:palletsort/screens/welcome_screen.dart';
import 'package:palletsort/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PalletSort',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: ThemeMode.dark,
      home: const WelcomeScreen(),
    );
  }
}

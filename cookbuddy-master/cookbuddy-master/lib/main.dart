import 'package:cookbuddy/theme/theme.dart';
import 'package:flutter/material.dart';
import 'screens/general/splash_screen.dart';

Future<void> main() async {
  runApp(CookBuddyApp());
}

class CookBuddyApp extends StatelessWidget {
  const CookBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Apply the light theme
      home: SplashScreen(), // Set the login page as the home
    );
  }
}

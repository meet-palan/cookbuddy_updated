import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Roboto', // Default Material Design font
    primarySwatch: Colors.orange,
    primaryColor: Colors.orangeAccent,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400), // Regular
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), // Bold
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.orangeAccent,
      foregroundColor: Colors.black, // AppBar text color
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent, // Button background color
        foregroundColor: Colors.black, // Button text color
      ),
    ),
  );
}

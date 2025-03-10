import 'dart:async';
import 'package:cookbuddy/screens/general/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cookbuddy/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to OnboardingScreen after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/splashscreen.json',
                fit: BoxFit.contain, // Adjusted height
              ),
              const SizedBox(height: 15), // Reduced spacing
              Text(
                'Cook Buddy',
                style: GoogleFonts.pacifico(
                  fontSize: 48, // Increased size
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                'Your Cooking Companion',
                style: GoogleFonts.lora(
                  fontSize: 22, // Increased size
                  color: AppColors.headingText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

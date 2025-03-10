import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user/login_screen.dart';
import '../admin/login_screen.dart';
import 'package:cookbuddy/utils/colors.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Beige Background
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo.png',
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),

              // Motivational Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '"Cooking is an art that begins with curiosity and grows with practice."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    color: Color(0xFF5D4037), // Dark Brown Text
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // App Name
              Text(
                'Cook Buddy',
                style: GoogleFonts.pacifico(
                  fontSize: 42,
                  color: AppColors.primary, // Orange Highlight,
                ),
              ),
              const SizedBox(height: 40),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserLoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: AppColors.buttonBackground, // Orange
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(370, 50),
                        elevation: 5,
                      ),
                      child: Text(
                        'User Login',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminLoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: AppColors.buttonBackground, // Orange
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(370, 50),
                        elevation: 5,
                      ),
                      child: Text(
                        'Admin Login',
                        style: GoogleFonts.lora(
                          fontSize: 20,
                          color: AppColors.buttonText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

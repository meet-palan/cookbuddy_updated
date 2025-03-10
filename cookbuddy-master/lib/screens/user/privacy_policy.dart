import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        backgroundColor: AppColors.appBar,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.headingText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome to Cook Buddy! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information.',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: AppColors.bodyText,
                ),
              ),
              const SizedBox(height: 20),
              _buildSection('1. Information We Collect',
                  'We may collect personal data such as your name, email, and app usage details to enhance your experience.'),
              _buildSection('2. How We Use Your Information',
                  'We use collected data to provide personalized recommendations, improve our services, and ensure security.'),
              _buildSection('3. Data Security',
                  'We prioritize your data security and implement industry-standard measures to protect your information.'),
              _buildSection('4. Third-Party Services',
                  'We may use third-party tools (e.g., Google Analytics) to analyze app performance without compromising your privacy.'),
              _buildSection('5. Your Choices',
                  'You can manage your data preferences within the app settings or contact us for data deletion requests.'),
              _buildSection('6. Updates to This Policy',
                  'We may update this Privacy Policy from time to time. We encourage you to review it periodically.'),
              const SizedBox(height: 10),
              Text(
                'For any questions or concerns, contact us at support@cookbuddy.com.',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: GoogleFonts.lora(
              fontSize: 16,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        backgroundColor: AppColors.appBar,
        title: Text(
          'About',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.headingText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('About our Cook Buddy App'),
              _buildText(
                  "Our Cook Buddy App is your ultimate companion for discovering, saving, and sharing delicious recipes. Whether you're a beginner or a pro chef, our app helps you cook with confidence!"),
              _buildSectionTitle('Key Features'),
              _buildFeatureSection(),
              _buildSectionTitle('Developer'),
              _buildText(
                  "Developed by Ritik Shah, passionate about making cooking easier for everyone!"),
              _buildSectionTitle('Contact & Support'),
              _buildText(
                  "For support or inquiries, contact us at: support@foodrecipeapp.com"),
              _buildSectionTitle('Version Info'),
              _buildText("Version 1.0.0"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.headingText,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.lora(
          fontSize: 16,
          color: AppColors.headingText,
        ),
      ),
    );
  }

  Widget _buildFeatureSection() {
    List<Map<String, dynamic>> features = [
      {
        "icon": Icons.search_rounded,
        "title": "Browse Recipes",
        "description":
            "Explore a variety of recipes with step-by-step instructions."
      },
      {
        "icon": Icons.filter_alt_outlined,
        "title": "Search & Filter",
        "description":
            "Easily find recipes based on ingredients, cuisine, or dietary preferences."
      },
      {
        "icon": Icons.favorite_border,
        "title": "Save Favorites",
        "description": "Keep track of your favorite recipes for quick access."
      },
      {
        "icon": Icons.star_border,
        "title": "Personalized Suggestions",
        "description": "Get recipe recommendations based on your preferences."
      },
      {
        "icon": Icons.mobile_friendly,
        "title": "Offline Access",
        "description": "Save recipes for use without an internet connection."
      },
    ];

    return Column(
      children: features
          .map((feature) => _buildFeature(
              feature["icon"], feature["title"], feature["description"]))
          .toList(),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.headingText, size: 28),
          SizedBox(width: 12),
          Expanded(
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
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.headingText,
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

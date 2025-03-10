import 'package:cookbuddy/screens/user/about.dart';
import 'package:cookbuddy/screens/user/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import 'login_screen.dart';
import 'privacy_policy.dart';

class SettingsPage extends StatefulWidget {
  final String userEmail;
  const SettingsPage({super.key, required this.userEmail});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        backgroundColor: AppColors.appBar,
        title: Text(
          'Settings',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.headingText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Column(
          children: [
            _buildSettingsOption(Icons.person, 'Profile', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userEmail: widget.userEmail)),
              );
            }),
            _buildSettingsOption(Icons.lock, 'Privacy & Security', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicy()),
              );
            }),
            _buildSettingsOption(Icons.info, 'About', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            }),
            _buildSettingsOption(Icons.logout, 'Log out', isLogout: true,
                onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserLoginScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String title,
      {bool isLogout = false, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.enabledBorder, width: 1),
        ),
        color: AppColors.background,
        child: ListTile(
          minTileHeight: 65,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: AppColors.background,
          leading: Icon(icon,
              color: isLogout ? Colors.red : AppColors.headingText, size: 26),
          title: Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isLogout ? Colors.red : AppColors.headingText,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              color: AppColors.headingText, size: 22),
          onTap: onTap,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
        ),
      ),
    );
  }
}

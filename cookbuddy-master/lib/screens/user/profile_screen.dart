import 'package:cookbuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({super.key, required this.userEmail});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  Map<String, dynamic>? _userData;
  bool _isPasswordVisible = false;

  final TextEditingController _subscribeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _subscribeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    _usernameFocusNode.addListener(() => setState(() {}));
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _subscribeFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Dispose of focus nodes to prevent memory leaks
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _subscribeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await _databaseHelper.getUserByEmail(widget.userEmail);
      if (user != null) {
        setState(() {
          _userData = user;
          _usernameController.text = user['username'] ?? '';
          _emailController.text = user['email'] ?? '';
          _passwordController.text = user['password'] ?? '';
        });
      }
    } catch (e) {
      _showSnackbar('Failed to fetch user data. Please try again later.');
    }
  }

  Future<void> _updateUserData() async {
    if (_userData != null) {
      final updatedUser = {
        'id': _userData!['id'],
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      try {
        await _databaseHelper.updateUser(updatedUser);
        setState(() {
          _userData = updatedUser;
        });
        _showSnackbar('Profile updated successfully!');
      } catch (e) {
        _showSnackbar('Failed to update profile. Please try again.');
      }
    }
  }

  Future<void> _subscribeUser() async {
    final email = widget.userEmail;
    final message = _subscribeController.text.trim();

    if (message.isEmpty) {
      _showSnackbar('Please enter a message before subscribing.');
      return;
    }

    try {
      final isSubscribed = await _databaseHelper.isUserSubscribed(email);
      if (isSubscribed) {
        _showSnackbar('You are already subscribed. Thank you!');
      } else {
        await _databaseHelper.subscribeUser(email, message);
        _showSnackbar('Subscription successful. Thank you!');
      }
    } catch (e) {
      _showSnackbar('Failed to subscribe. Please try again later.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: true,
        title: Text(
          "Profile",
          style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
              fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBar,
      ),
      backgroundColor: AppColors.background,
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.appBar,
                        child: Text(
                          (_userData?['username'] ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.lora(
                            fontSize: 40,
                            color: AppColors.headingText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Hello, ${_userData?['username'] ?? 'User'}! ',
                        style: GoogleFonts.lora(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildEditableField(
                      label: 'Username',
                      controller: _usernameController,
                      icon: Icons.person,
                      focusNode: _usernameFocusNode,
                    ),
                    const SizedBox(height: 15),
                    _buildEditableField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email,
                      focusNode: _emailFocusNode,
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          disabledForegroundColor: AppColors.hintText,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.lora(
                              fontSize: 18,
                              color: AppColors.buttonText,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        _buildEditableField(
                          label: 'Subscribe',
                          controller: _subscribeController,
                          icon: Icons.subscriptions,
                          focusNode: _subscribeFocusNode,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _subscribeUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              disabledForegroundColor: AppColors.hintText,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Subscribe',
                              style: GoogleFonts.lora(
                                  fontSize: 18,
                                  color: AppColors.buttonText,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required FocusNode focusNode,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lora(
          color: AppColors.hintText,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.hintText,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.hintText, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.buttonBackground, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: GoogleFonts.lora(
          color: _passwordFocusNode.hasFocus
              ? Colors.orangeAccent
              : AppColors.hintText,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: _passwordFocusNode.hasFocus
              ? Colors.orangeAccent
              : AppColors.hintText,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: _passwordFocusNode.hasFocus
                ? Colors.orangeAccent
                : AppColors.hintText,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.hintText, width: 2.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

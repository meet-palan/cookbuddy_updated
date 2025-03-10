import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart'; // Import DatabaseHelper
import 'login_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Function to handle user registration
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dbHelper = DatabaseHelper.instance;

        // Check if email already exists
        final db = await dbHelper.database;
        final existingUsers = await db.query(
          'Users',
          where: 'email = ?',
          whereArgs: [_emailController.text.trim()],
        );

        if (existingUsers.isNotEmpty) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Email already in use. Please use another.")),
          );
          return;
        }

        // Insert new user
        await db.insert(
          'Users',
          {
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
        );

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registration successful! Please login.")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserLoginScreen()),
        );
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to register. Please try again.")),
        );
      }
    }
  }

  // Reusable text field widget
  Widget _buildTextField({
    required String labelText,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputAction textInputAction = TextInputAction.next,
    required String? Function(String?) validator,
    VoidCallback? onToggleVisibility,
    bool obscureText = false,
  }) {
    final focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        focusNode.addListener(() {
          setState(() {}); // Rebuild the widget when focus changes
        });

        return TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: GoogleFonts.lora(
              color: focusNode.hasFocus
                  ? AppColors.buttonBackground
                  : AppColors.hintText,
            ),
            prefixIcon: Icon(
              icon,
              color: focusNode.hasFocus
                  ? AppColors.buttonBackground
                  : AppColors.hintText,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.hintText,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.focusedBorder, width: 2.0),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.hintText, width: 2.0),
              borderRadius: BorderRadius.circular(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: validator,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png', // Replace with your app logo
                      height: 150,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Create Account',
                      style: GoogleFonts.lora(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign up to start your journey with us.',
                      style: GoogleFonts.lora(
                          fontSize: 16, color: AppColors.headingText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      labelText: 'Username',
                      icon: Icons.person,
                      controller: _usernameController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your username'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      labelText: 'Email',
                      icon: Icons.email,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      labelText: 'Password',
                      icon: Icons.lock,
                      controller: _passwordController,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      labelText: 'Confirm Password',
                      icon: Icons.lock,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Register',
                          style: GoogleFonts.lora(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.lora(
                        fontSize: 16,
                        color: AppColors.headingText,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserLoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: GoogleFonts.lora(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

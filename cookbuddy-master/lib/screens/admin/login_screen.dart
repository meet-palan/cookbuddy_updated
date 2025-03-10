import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'dashboard_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // FocusNodes for the TextFormFields
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Color _emailIconColor = AppColors.hintText;
  Color _passwordIconColor = AppColors.hintText;

  @override
  void initState() {
    super.initState();

    // Add listeners to the FocusNodes
    _emailFocusNode.addListener(() {
      setState(() {
        _emailIconColor =
            _emailFocusNode.hasFocus ? Colors.orangeAccent : AppColors.hintText;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordIconColor = _passwordFocusNode.hasFocus
            ? Colors.orangeAccent
            : AppColors.hintText;
      });
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        bool isValid =
            await _dbHelper.validateAdminCredentials(email, password);
        setState(() {
          _isLoading = false;
        });

        if (isValid) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          _showMessage("Invalid email or password");
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _showMessage("An error occurred. Please try again.");
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/logo.png',
                height: 150,
              ),
              const SizedBox(height: 5),
              Text(
                "Admin Login",
                style: GoogleFonts.lora(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: GoogleFonts.lora(
                        color: _emailFocusNode.hasFocus
                            ? AppColors.focusedBorder
                            : AppColors.hintText,
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: _emailIconColor,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.orangeAccent, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.hintText, width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: GoogleFonts.lora(
                        color: _passwordFocusNode.hasFocus
                            ? AppColors.buttonBackground
                            : AppColors.hintText,
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: _passwordIconColor,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.orangeAccent, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.hintText, width: 2.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _passwordFocusNode.hasFocus
                              ? AppColors.buttonBackground
                              : AppColors.hintText,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 32.0,
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.buttonBackground)
                          : Text(
                              "Log In",
                              style: GoogleFonts.lora(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Contact your administrator if you encounter any issues.\n"
                "Email: meet@gmail.com",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.headingText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

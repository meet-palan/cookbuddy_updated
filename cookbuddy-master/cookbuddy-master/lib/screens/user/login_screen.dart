import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:cookbuddy/screens/user/home_screen.dart';
import 'package:cookbuddy/screens/user/register_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbuddy/utils/colors.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _validateUser(String email, String password) async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.validateUserCredentials(email, password);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final isValid = await _validateUser(email, password);
      setState(() => _isLoading = false);

      if (isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserHomeScreen(userEmail: email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password.")),
        );
      }
    }
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
              const SizedBox(height: 50),
              Image.asset('assets/logo.png', height: 150),
              const SizedBox(height: 10),
              Text(
                "Welcome Back!",
                style: GoogleFonts.lora(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                label: "Email",
                icon: Icons.email,
                isPassword: false,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                label: "Password",
                icon: Icons.lock,
                isPassword: true,
                togglePasswordVisibility: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                isPasswordVisible: _isPasswordVisible,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.buttonBackground)
                    : Text(
                        'Log In',
                        style: GoogleFonts.lora(
                            fontSize: 18,
                            color: AppColors.buttonText,
                            fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.lora(
                        fontSize: 16,
                        color: AppColors.headingText,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.lora(
                          color: Colors.orangeAccent,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required bool isPassword,
    bool? isPasswordVisible,
    void Function()? togglePasswordVisibility,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !(isPasswordVisible ?? false),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lora(
          color: focusNode.hasFocus ? Colors.orangeAccent : Color(0xFF8D6E63),
        ),
        prefixIcon: Icon(
          icon,
          color: focusNode.hasFocus ? Colors.orangeAccent : Color(0xFF8D6E63),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible! ? Icons.visibility : Icons.visibility_off,
                  color: focusNode.hasFocus
                      ? Colors.orangeAccent
                      : Color(0xFF8D6E63),
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
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
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: isPassword ? (_) => _login() : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == "Email" &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        if (label == "Password" && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}

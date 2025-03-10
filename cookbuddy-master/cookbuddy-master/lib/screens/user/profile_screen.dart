import 'package:cookbuddy/screens/user/home_screen.dart';
import 'package:cookbuddy/screens/user/meal_planner_screen.dart';
import 'package:cookbuddy/screens/user/my_recipes_screen.dart';
import 'package:cookbuddy/screens/user/recipe_selling_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
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

  int _currentIndex = 4;

  final TextEditingController _subscribeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus nodes for all fields
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _subscribeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    // Add listeners to focus nodes
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

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserHomeScreen(userEmail: widget.userEmail)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyRecipesScreen(userEmail: widget.userEmail)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RecipeSellingPage(currentUserEmail: widget.userEmail)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MealPlannerScreen(userEmail: widget.userEmail)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(userEmail: widget.userEmail)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
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
                padding: const EdgeInsets.all(16.0),
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
                        'Hello, ${_userData?['username'] ?? 'User'}!',
                        style: GoogleFonts.lora(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildEditableField(
                            label: 'Username',
                            controller: _usernameController,
                            icon: Icons.person,
                            focusNode: _usernameFocusNode,
                          ),
                          const SizedBox(height: 10),
                          _buildEditableField(
                            label: 'Email',
                            controller: _emailController,
                            icon: Icons.email,
                            focusNode: _emailFocusNode,
                          ),
                          const SizedBox(height: 10),
                          _buildPasswordField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildCard(
                      child: Column(
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text(
                                'Subscribe',
                                style: TextStyle(fontSize: 18),
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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
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
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lora(
          color: focusNode.hasFocus
              ? AppColors.focusedBorder
              : AppColors.headingText,
        ),
        prefixIcon: Icon(
          icon,
          color: focusNode.hasFocus
              ? Colors.orangeAccent
              : const Color(0xFF8D6E63),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.headingText, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.buttonBackground, width: 2.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              : const Color(0xFF8D6E63),
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: _passwordFocusNode.hasFocus
              ? Colors.orangeAccent
              : const Color(0xFF8D6E63),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: _passwordFocusNode.hasFocus
                ? Colors.orangeAccent
                : const Color(0xFF8D6E63),
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

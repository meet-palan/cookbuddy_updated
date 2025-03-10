import 'dart:typed_data';
import 'package:cookbuddy/screens/general/get_started_screen.dart';
import 'package:cookbuddy/screens/user/meal_planner_screen.dart';
import 'package:cookbuddy/screens/user/my_recipes_screen.dart';
import 'package:cookbuddy/screens/user/recipe_selling_screen.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
import 'package:cookbuddy/widgets/recipe_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:cookbuddy/screens/user/profile_screen.dart';
import 'package:cookbuddy/utils/colors.dart';

class UserHomeScreen extends StatefulWidget {
  final String userEmail;

  const UserHomeScreen({super.key, required this.userEmail});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  String _username = "";
  int _credits = 0;
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;
  List<Map<String, dynamic>> _recipes = []; // For storing recipes

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _fetchRecipes();
    _assignCreditsToExistingUsers();
  }

  Future<void> _initializeUserData() async {
    final user = await _databaseHelper.getUserByEmail(widget.userEmail);
    if (user != null) {
      setState(() {
        _username = user['username'];
        _credits = user['credits'] ?? 0;
      });
    }
  }

  Future<void> _assignCreditsToExistingUsers() async {
    await _databaseHelper.assignInitialCredits();
    await _initializeUserData(); // Update AppBar credits after assigning
  }

  /// Periodically refresh credits every 2 seconds
  void _startCreditsRefresh() {
    Future.delayed(const Duration(seconds: 2), () async {
      final user = await _databaseHelper.getUserByEmail(widget.userEmail);
      if (user != null && user['credits'] != _credits) {
        setState(() {
          _credits = user['credits'] ?? 0;
        });
      }
      _startCreditsRefresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch recipes with BLOB image data from the database
  Future<void> _fetchRecipes() async {
    final db = await _databaseHelper.database;
    final recipes = await db.rawQuery('''
      SELECT r.id AS recipeId,
             r.name AS recipeName,
             r.image AS recipeImage,
             r.insertedBy AS insertedBy,
             r.ingredients AS ingredients,
             r.instructions AS instructions,
             r.time AS time
      FROM Recipes r
    ''');
    setState(() {
      _recipes = recipes;
    });
  }

  /// Build image from Uint8List (BLOB)
  Widget _buildImage(Uint8List? imageBytes) {
    if (imageBytes != null && imageBytes.isNotEmpty) {
      return Image.memory(
        imageBytes,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, size: 50);
        },
      );
    } else {
      return const Icon(Icons.image_not_supported, size: 50);
    }
  }

  void _logOut(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
    );
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
    _startCreditsRefresh(); // Start the credits refresh process
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 160, // Increased toolbar height
        backgroundColor: AppColors.appBar,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                userEmail: widget.userEmail,
                              )),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20, // Adjust size as needed
                    backgroundColor: AppColors.background,
                    child: Text(
                      _username.isNotEmpty
                          ? _username[0].toUpperCase()
                          : "U", // Show first letter
                      style: GoogleFonts.lora(
                        fontSize: 22,
                        color: AppColors.headingText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $_username!",
                      style: GoogleFonts.lora(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.headingText),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.lora(
                          fontSize: 15, color: AppColors.headingText),
                    ),
                  ],
                ),
                Spacer(), // Pushes the icon button to the right
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: AppColors.headingText,
                    size: 30,
                  ),
                  onPressed: () {
                    // Handle settings button press
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: GoogleFonts.lora(
                          fontSize: 18,
                          color: AppColors.hintText,
                          fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.hintText,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recipes",
              style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText),
            ),
            Expanded(
              child: _recipes.isEmpty
                  ? Center(
                      child: Text(
                        "No recipes available.",
                        style: GoogleFonts.lora(
                            fontSize: 18, color: AppColors.headingText),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        // Fetching the image as Uint8List
                        final imageBytes = recipe['recipeImage'] as Uint8List?;
                        return RecipeCard(
                          title: recipe['recipeName'] ?? "Unknown",
                          imageBytes: imageBytes,
                          time: recipe['time'] ?? "N/A",
                          author: recipe['insertedBy'] ?? "Unknown",
                          rating:
                              4.8, // Static for now, replace with DB value if available
                          isFavorite: false, // Implement favorite logic
                          onFavoritePressed: () {
                            // Handle favorite button press
                          },
                          onEditPressed: () {},
                          onDeletePressed: () {},
                          onTap: () {
                            print("Recipe Clicked");
                          },
                          showFavorite: true, showMenu: false,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}

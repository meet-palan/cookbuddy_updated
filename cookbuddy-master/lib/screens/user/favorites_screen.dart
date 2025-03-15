import 'dart:typed_data';
import 'package:cookbuddy/screens/user/recipe_details_screen.dart';
import 'package:cookbuddy/screens/user/recipe_selling_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'meal_planner_screen.dart';
import 'my_recipes_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final String userEmail;

  const FavoriteScreen({super.key, required this.userEmail});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _favoriteRecipes = [];
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
  }

  /*Future<void> _loadFavoriteRecipes() async {
    final favorites = await _databaseHelper.getFavoriteRecipes();

    // Create a mutable copy of each recipe and fetch category names
    final List<Map<String, dynamic>> updatedFavorites = [];
    for (var recipe in favorites) {
      final mutableRecipe = Map<String, dynamic>.from(recipe); // Create a mutable copy
      if (mutableRecipe['categoryId'] != null) {
        final categoryName = await _databaseHelper.getCategoryName(mutableRecipe['categoryId']);
        mutableRecipe['categoryName'] = categoryName; // Add categoryName
      } else {
        mutableRecipe['categoryName'] = "Unknown";
      }
      updatedFavorites.add(mutableRecipe);
    }

    setState(() {
      _favoriteRecipes = updatedFavorites;
    });
  }*/

  /*Future<void> _removeFromFavorites(int recipeId) async {
    await _databaseHelper.toggleFavorite(recipeId, false);
    _loadFavoriteRecipes(); // Refresh the favorites list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Removed from favorites.")),
    );
  }*/

  Future<void> _loadFavoriteRecipes() async {
    final user = await _databaseHelper.getUserByEmail(widget.userEmail);
    if (user == null) return;

    int userId = user['id'];
    final favorites = await _databaseHelper.getUserFavorites(userId); // Fetch only the user's favorites

    final List<Map<String, dynamic>> updatedFavorites = [];
    for (var recipe in favorites) {
      final mutableRecipe = Map<String, dynamic>.from(recipe);
      if (mutableRecipe['categoryId'] != null) {
        final categoryName = await _databaseHelper.getCategoryName(mutableRecipe['categoryId']);
        mutableRecipe['categoryName'] = categoryName;
      } else {
        mutableRecipe['categoryName'] = "Unknown";
      }
      updatedFavorites.add(mutableRecipe);
    }

    setState(() {
      _favoriteRecipes = updatedFavorites;
    });
  }



  Future<void> _removeFromFavorites(int recipeId) async {
    final user = await _databaseHelper.getUserByEmail(widget.userEmail);
    if (user == null) return;

    int userId = user['id'];
    await _databaseHelper.toggleFavorite(userId, recipeId, false);

    _loadFavoriteRecipes(); // Refresh the favorites list

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Removed from favorites.")),
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
              builder: (context) => FavoriteScreen(userEmail: widget.userEmail)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Favorites",
            style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: AppColors.headingText,
                fontSize: 22),
          ),
          backgroundColor: AppColors.appBar,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: AppColors.background,
        body: _favoriteRecipes.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "No favorite recipes yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _favoriteRecipes.length,
          itemBuilder: (context, index) {
            final recipe = _favoriteRecipes[index];
            Uint8List? recipeImage = recipe['image'];

            return Card(
              margin:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: recipeImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    recipeImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.fastfood,
                  size: 60,
                  color: Colors.grey,
                ),
                title: Text(
                  recipe['name'] ?? "Unnamed Recipe",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "Category: ${recipe['categoryName'] ?? "N/A"}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _removeFromFavorites(recipe['id']),
                ),
                onTap: () async {
                  final isFavorite = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipeId: recipe['id'],
                        userEmail: widget.userEmail,
                      ),
                    ),
                  );

                  if (isFavorite == false) {
                    _loadFavoriteRecipes(); // Refresh the favorite list
                  }
                },
              ),
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
        ),
      ),
    );
  }
}





/*import 'dart:typed_data';
import 'package:cookbuddy/screens/user/home_screen.dart';
import 'package:cookbuddy/screens/user/meal_planner_screen.dart';
import 'package:cookbuddy/screens/user/my_recipes_screen.dart';
import 'package:cookbuddy/screens/user/recipe_details_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
import 'package:cookbuddy/widgets/recipe_card.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import 'recipe_selling_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final String userEmail;
  const FavoriteScreen({super.key, required this.userEmail});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _favoriteRecipes = [];
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
  }

  Future<void> _loadFavoriteRecipes() async {
    final favorites = await _databaseHelper.getFavoriteRecipes();

    // Create a mutable copy of each recipe and fetch category names
    final List<Map<String, dynamic>> updatedFavorites = [];
    for (var recipe in favorites) {
      final mutableRecipe =
          Map<String, dynamic>.from(recipe); // Create a mutable copy
      if (mutableRecipe['categoryId'] != null) {
        final categoryName =
            await _databaseHelper.getCategoryName(mutableRecipe['categoryId']);
        mutableRecipe['categoryName'] = categoryName; // Add categoryName
      } else {
        mutableRecipe['categoryName'] = "Unknown";
      }
      updatedFavorites.add(mutableRecipe);
    }

    setState(() {
      _favoriteRecipes = updatedFavorites;
    });
  }

  Future<void> _removeFromFavorites(int recipeId) async {
    await _databaseHelper.toggleFavorite(recipeId, false);
    _loadFavoriteRecipes(); // Refresh the favorites list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Removed from favorites.")),
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
              builder: (context) =>
                  FavoriteScreen(userEmail: widget.userEmail)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        title: Text(
          "Favorites",
          style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.headingText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBar,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _favoriteRecipes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No favorite recipes yet.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = _favoriteRecipes[index];
                  final imageBytes = recipe['image'] as Uint8List?;

                  return RecipeCard(
                    title: recipe['name'] ?? "Unnamed Recipe",
                    imageBytes: imageBytes,
                    authorOrCategory: recipe['categoryName'] ?? "N/A",
                    rating: 4.8,
                    time: recipe['time'] ?? "N/A",
                    isFavorite: false, // Implement favorite logic
                    onFavoritePressed: () {},
                    onEditPressed: () {},
                    onDeletePressed: () {},
                    showFavorite: false, showMenu: false, isCategory: true,
                    onTap: () {
                      // Navigate to RecipeDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipeId: recipe['id']),
                        ),
                      );
                      print("isCategory passed: ${true}");
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
*/

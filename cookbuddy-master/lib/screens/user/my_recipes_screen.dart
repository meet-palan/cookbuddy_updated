import 'dart:typed_data';
import 'package:cookbuddy/screens/user/editrecipescreen.dart';
import 'package:cookbuddy/screens/user/favorites_screen.dart';
import 'package:cookbuddy/screens/user/home_screen.dart';
import 'package:cookbuddy/screens/user/meal_planner_screen.dart';
import 'package:cookbuddy/screens/user/recipe_selling_screen.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/recipe_card.dart';

class MyRecipesScreen extends StatefulWidget {
  final String userEmail;

  const MyRecipesScreen({super.key, required this.userEmail});

  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> myRecipes = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = false;

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchMyRecipes();
    _fetchCategories();
  }

  Future<void> _fetchMyRecipes() async {
    setState(() {
      isLoading = true;
    });

// Fetch recipes uploaded by the user
    List<Map<String, dynamic>> fetchedRecipes =
        await _databaseHelper.getRecipesByEmail(widget.userEmail);

    List<Map<String, dynamic>> updatedRecipes = [];

    for (var recipe in fetchedRecipes) {
      // Fetch average rating for each recipe
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
      SELECT AVG(rating) AS avgRating FROM CommentAndRating WHERE recipeId = ?
    ''', [recipe['id']]);

      double avgRating =
          (result.isNotEmpty && result.first['avgRating'] != null)
              ? double.parse(
                  (result.first['avgRating'] as double).toStringAsFixed(1))
              : 0.0;

      // Create a new mutable map instead of modifying the original read-only map
      updatedRecipes.add({
        ...recipe, // Copy existing data
        'avgRating': avgRating, // Add/modify the avgRating field
      });
    }

    setState(() {
      myRecipes = updatedRecipes;
      isLoading = false;
    });
  }

  Future<void> _fetchCategories() async {
    categories = await _databaseHelper.getAllCategories();
    setState(() {});
  }

  Future<void> _updateRecipe(int id, String name, String ingredients,
      String instructions, String? time) async {
    final db = await _databaseHelper.database;
    await db.update(
      'Recipes',
      {
        'name': name,
        'ingredients': ingredients,
        'instructions': instructions,
        'time': time,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await _fetchMyRecipes(); // Refresh the recipe list

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Recipe updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteRecipe(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('Recipes', where: 'id = ?', whereArgs: [id]);
    await _fetchMyRecipes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Recipe deleted successfully"),
        backgroundColor: Colors.orangeAccent,
      ),
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

  void _showAddRecipeModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ingredientsController = TextEditingController();
    final TextEditingController instructionsController =
        TextEditingController();
    final TextEditingController youtubeController = TextEditingController();
    Uint8List? selectedImage;
    int? selectedCategoryId;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      backgroundColor: AppColors.background,
      context: context,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Add Recipe",
                style: GoogleFonts.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBar,
                  foregroundColor: AppColors.hintText,
                ),
                onPressed: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    selectedImage = await pickedFile.readAsBytes();
                    setState(() {});
                  }
                },
                icon: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                ),
                label: Text(
                  "Add Image",
                  style: GoogleFonts.lora(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              selectedImage != null
                  ? Image.memory(
                      selectedImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Text(
                      "No image selected",
                      style: GoogleFonts.lora(
                        color: AppColors.headingText,
                        fontSize: 18,
                      ),
                    ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.hintText,
                      width: 1, // Default border color
                    ),
                  ),
                  labelText: "Recipe Name",
                  labelStyle: GoogleFonts.lora(
                    color: AppColors.hintText, // Label text color
                  ),
                  floatingLabelStyle:
                      GoogleFonts.lora(color: Colors.orangeAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ingredientsController,
                maxLines: 3,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.hintText,
                      width: 1, // Default border color
                    ),
                  ),
                  labelText: "Ingredients",
                  labelStyle: GoogleFonts.lora(
                    color: AppColors.hintText, // Label text color
                  ),
                  floatingLabelStyle:
                      GoogleFonts.lora(color: Colors.orangeAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.hintText,
                      width: 1, // Default border color
                    ),
                  ),
                  labelText: "Instructions",
                  labelStyle: GoogleFonts.lora(
                    color: AppColors.hintText, // Label text color
                  ),
                  floatingLabelStyle:
                      GoogleFonts.lora(color: Colors.orangeAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                items: categories
                    .map((category) => DropdownMenuItem<int>(
                          value: category['id'],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Text(
                              category['name'],
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                color:
                                    AppColors.headingText, // Match theme color
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color:
                      AppColors.headingText, // Ensure text color is consistent
                ),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.hintText,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.orangeAccent, width: 2),
                  ),
                  labelText: "Select Category",
                  labelStyle: GoogleFonts.lora(
                    fontSize: 16,
                    color: AppColors.hintText,
                  ),
                  floatingLabelStyle: GoogleFonts.lora(
                    fontSize: 18,
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                dropdownColor: AppColors.background, // Match theme background
                borderRadius: BorderRadius.circular(12), // Rounded dropdown
                elevation: 2, // Slight shadow effect
              ),
              const SizedBox(height: 16),
              TextField(
                controller: youtubeController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.hintText,
                      width: 1, // Default border color
                    ),
                  ),
                  labelText: "YouTube Link",
                  labelStyle: GoogleFonts.lora(
                      color: AppColors.hintText // Label text color
                      ),
                  floatingLabelStyle:
                      GoogleFonts.lora(color: Colors.orangeAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      selectedTime != null
                          ? "Selected Time: ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                          : "No time selected",
                      style: GoogleFonts.lora(
                        color: AppColors.headingText,
                      )),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: AppColors.hintText,
                    ),
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor:
                                    Colors.white, // Background color
                                hourMinuteColor: WidgetStateColor.resolveWith(
                                    (states) => Colors
                                        .white), // Background of selected time box
                                hourMinuteTextColor: Colors
                                    .orangeAccent, // Text color inside the box
                                dialHandColor:
                                    Colors.orangeAccent, // Dial hand color
                                dialBackgroundColor: Colors
                                    .orange.shade100, // Dial background color
                                entryModeIconColor: Colors
                                    .orangeAccent, // Entry mode icon color
                              ),
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            ),
                          );
                        },
                      );

                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Text(
                      "Select Time",
                      style: GoogleFonts.lora(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    disabledForegroundColor: AppColors.hintText,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        ingredientsController.text.isEmpty ||
                        instructionsController.text.isEmpty ||
                        selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all mandatory fields"),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.background,
                        title: Text(
                          "Upload Options",
                          style: GoogleFonts.lora(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingText,
                          ),
                        ),
                        content: Text(
                          "Do you want to sell this recipe?",
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            color: AppColors.headingText,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _databaseHelper.addRecipeByUser(
                                {
                                  "name": nameController.text,
                                  "ingredients": ingredientsController.text,
                                  "instructions": instructionsController.text,
                                  "categoryId": selectedCategoryId,
                                  "youtubeLink": youtubeController.text,
                                  "time": selectedTime != null
                                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : null,
                                  "image": selectedImage,
                                },
                                widget.userEmail,
                              );
                              Navigator.pop(context);
                              _fetchMyRecipes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Recipe uploaded successfully",
                                    style:
                                        GoogleFonts.lora(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.orangeAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: Text(
                              "Post",
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final isListed = await _databaseHelper
                                  .isRecipeAlreadyListedForSale(
                                      nameController.text, widget.userEmail);
                              if (isListed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "This recipe is already listed for sale.",
                                      style:
                                          GoogleFonts.lora(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.orangeAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              } else {
                                _showSellRecipeModal(
                                    context,
                                    nameController.text,
                                    selectedCategoryId,
                                    selectedImage);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: Text(
                              "Sell",
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    "Upload",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSellRecipeModal(BuildContext context, String recipeName,
      int? categoryId, Uint8List? image) {
    final TextEditingController creditsController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sell Recipe"),
        content: TextField(
          controller: creditsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Enter Credits to Sell Recipe",
            floatingLabelStyle: GoogleFonts.lora(color: Colors.orangeAccent),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final credits = int.tryParse(creditsController.text);
              if (credits != null && credits > 0) {
                await _databaseHelper.addSellingRecipe({
                  "name": recipeName,
                  "categoryId": categoryId,
                  "image": image,
                  "credits": credits,
                  "userEmail": widget.userEmail,
                });
                Navigator.pop(context); // Close the add recipe modal
                _fetchMyRecipes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Your Recipe listed for sale!"),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid credits value"),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
              }
            },
            child: Text(
              "Set",
              style: GoogleFonts.lora(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Text(
          "My Recipes",
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.headingText,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBar,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: myRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = myRecipes[index];
                  final imageBytes = recipe['image'] as Uint8List?;

                  return RecipeCard(
                    title: recipe['name'] ?? "Unknown",
                    imageBytes: imageBytes,
                    time: recipe['time'] ?? "N/A",
                    authorOrCategory: recipe['uploaderName'] ?? "Unknown",
                    rating: recipe['avgRating'] ??
                        0.0, // Static for now, replace with DB value if available
                    isFavorite: false, // Implement favorite logic
                    showFavorite: false, showMenu: true, isCategory: false,
                    onFavoritePressed: () {
                      // Handle favorite button press
                    },
                    onEditPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecipeScreen(
                            recipeId: recipe['id'],
                            initialName: recipe['name'],
                            initialIngredients: recipe['ingredients'],
                            initialInstructions: recipe['instructions'],
                            initialTime: recipe['time'],
                            initialImage: recipe['image'],
                            onUpdateRecipe: _updateRecipe,
                          ),
                        ),
                      );
                    },
                    onDeletePressed: () {
                      _deleteRecipe(recipe['id']);
                    },
                    onTap: () {
                      print("Recipe Clicked");
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appBar,
        onPressed: () => _showAddRecipeModal(context),
        child: const Icon(
          Icons.add,
          color: AppColors.background,
          size: 28,
        ),
      ),
    );
  }
}

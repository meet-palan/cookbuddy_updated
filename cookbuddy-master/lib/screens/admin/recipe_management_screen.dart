import 'dart:typed_data';
import 'package:cookbuddy/screens/admin/admin_bottom_navbar.dart';
import 'package:cookbuddy/widgets/recipe_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cookbuddy/database/database_helper.dart';
import '../../utils/colors.dart';
import '../user/editrecipescreen.dart';

class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  _RecipeManagementScreenState createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = false;
  int _selectedIndex = 1;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await _fetchRecipes();
    await _fetchCategories();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchRecipes() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
    SELECT Recipes.*,
           Users.username AS userName,
           (SELECT AVG(rating) FROM CommentAndRating WHERE CommentAndRating.recipeId = Recipes.id) AS avgRating
    FROM Recipes
    LEFT JOIN Users ON Recipes.uploaderId = Users.id
    WHERE Recipes.insertedBy = 'admin'
  ''');

    setState(() {
      recipes = result.map((recipe) {
        double avgRating = (recipe['avgRating'] as double?) ?? 0.0;
        return {
          ...recipe, // Copy all existing key-value pairs
          'avgRating':
              double.parse(avgRating.toStringAsFixed(1)), // Round to 1 decimal
        };
      }).toList();
    });
  }

  Future<void> _fetchCategories() async {
    final db = await _databaseHelper.database;
    final result = await db.query('Categories'); // Fetch all categories
    categories = result;
  }

  Future<void> _deleteRecipe(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('Recipes', where: 'id = ?', whereArgs: [id]);
    await _fetchRecipes();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe deleted successfully")),
    );
  }

  Future<void> _updateRecipe(int id, String name, String ingredients,
      String instructions, String youtubeLink, String? time) async {
    final db = await _databaseHelper.database;
    await db.update(
      'Recipes',
      {
        'name': name,
        'ingredients': ingredients,
        'instructions': instructions,
        'youtubeLink': youtubeLink,
        'time': time,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: Colors.black,
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
                  color: AppColors.buttonText,
                ),
                label: Text(
                  "Add Image",
                  style: GoogleFonts.lora(
                      color: AppColors.buttonText, fontSize: 15),
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
                                horizontal: 10), // Matches dropdown size
                            child: Text(
                              category['name'],
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    AppColors.headingText, // Themed text color
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedCategoryId = value;
                },
                dropdownColor: AppColors.background, // Matches theme
                style: GoogleFonts.lora(
                  // Default text style inside dropdown
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.headingText,
                ),
                menuMaxHeight:
                    250, // Makes the list scrollable if it exceeds this height
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.hintText,
                      width: 1, // Default border color
                    ),
                  ),
                  labelText: "Select Category",
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
                    await _databaseHelper.addRecipe({
                      "name": nameController.text,
                      "ingredients": ingredientsController.text,
                      "instructions": instructionsController.text,
                      "categoryId": selectedCategoryId,
                      "youtubeLink": youtubeController.text,
                      "time": selectedTime != null
                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          : null,
                      "image": selectedImage,
                      "insertedBy": "admin", // Admin role
                    });
                    Navigator.pop(context);
                    await _fetchRecipes();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Uploaded successfully")),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          title: Text(
            "Recipe Management",
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
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    final imageBytes = recipe['image'] as Uint8List?;
                    return RecipeCard(
                      title: recipe['name'] ?? "Unknown",
                      imageBytes: imageBytes,
                      authorOrCategory: recipe['insertedBy'] == 'admin'
                          ? 'Admin'
                          : recipe['userName'] ?? 'Unknown',
                      time: recipe['time'] ?? 'N/A',
                      rating: recipe['avgRating'] ?? 0.0,
                      isFavorite: false,
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
                              initialyoutubeLink: recipe['youtubeLink'],
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
                      showFavorite: false,
                      showMenu: true,
                      isCategory: false,
                    );
                  },
                ),
        ),
        bottomNavigationBar: AdminBottomNavigationBar(
            currentIndex: _selectedIndex, onTap: _onNavItemTapped),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.buttonBackground,
          onPressed: () => _showAddRecipeModal(context),
          child: const Icon(
            Icons.add,
            color: AppColors.background,
            size: 28,
          ),
        ),
      ),
    );
  }
}

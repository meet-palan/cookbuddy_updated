import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';
import 'admin_bottom_navbar.dart';
// Import the DatabaseHelper class

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> categories = [];

  int _selectedIndex = 2;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final result = await _dbHelper.getAllCategories();
    setState(() {
      categories = result;
    });
  }

  Future<void> _addCategory(String categoryName) async {
    // Check if the category already exists
    final existingCategories = categories
        .where((category) =>
            category['name'].toString().toLowerCase() ==
            categoryName.toLowerCase())
        .toList();

    if (existingCategories.isNotEmpty) {
      _showSnackBar("Try different category, this is already present.");
      return;
    }

    // Insert the category into the database
    await _dbHelper.addCategory({'name': categoryName});
    await _fetchCategories();
    _showSnackBar("Category added successfully.");
  }

  Future<void> _deleteCategory(int categoryId) async {
    bool? confirmDelete = await _showConfirmationDialog();
    if (confirmDelete ?? false) {
      await _dbHelper.deleteCategory(categoryId);
      await _fetchCategories();
      _showSnackBar("Category deleted successfully.");
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddCategoryModal() {
    final TextEditingController categoryController = TextEditingController();
    showModalBottomSheet(
      backgroundColor: AppColors.background,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => Padding(
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
              "Add Category",
              style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelStyle: GoogleFonts.lora(color: AppColors.hintText),
                labelText: "Category Name",
                floatingLabelStyle:
                    GoogleFonts.lora(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.hintText),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
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
                onPressed: () {
                  final categoryName = categoryController.text.trim();
                  if (categoryName.isNotEmpty) {
                    _addCategory(categoryName);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Add",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Text(
          "Category Management",
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: categories.isEmpty
            ? Center(
                child: Text("No categories available.",
                    style: GoogleFonts.lora(
                        fontSize: 18, color: AppColors.headingText)))
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Dismissible(
                    key: Key(
                        category['id'].toString()), // Unique key for each item
                    direction:
                        DismissDirection.endToStart, // Swipe from right to left
                    background: Container(
                      margin: const EdgeInsets.only(
                          bottom: 10.0), // Match card spacing
                      decoration: BoxDecoration(
                        color: Colors
                            .red.shade400, // Softer red tone for better UX
                        borderRadius: BorderRadius.circular(
                            12), // Rounded corners like the card
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerRight,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Delete",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(Icons.delete, color: Colors.white, size: 30),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      bool? shouldDelete = await _showConfirmationDialog();
                      return shouldDelete; // Return true to delete, false to cancel
                    },
                    onDismissed: (direction) {
                      // This executes ONLY IF confirmDismiss returns true
                      _deleteCategory(category['id']);
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      color: AppColors.background,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.hintText, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 6),
                        child: ListTile(
                          title: Text(
                            category['name'],
                            style: GoogleFonts.lora(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.headingText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: AdminBottomNavigationBar(
          currentIndex: _selectedIndex, onTap: _onNavItemTapped),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.buttonBackground,
        foregroundColor: Colors.black,
        onPressed: _showAddCategoryModal,
        child: const Icon(
          Icons.add,
          color: AppColors.background,
          size: 28,
        ),
      ),
    );
  }
}

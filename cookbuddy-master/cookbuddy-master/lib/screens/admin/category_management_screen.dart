import 'package:cookbuddy/screens/admin/recipe_management_screen.dart';
import 'package:cookbuddy/screens/admin/user_management_screen.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:iconly/iconly.dart';

import 'dashboard_screen.dart'; // Import the DatabaseHelper class

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
      backgroundColor: Colors.white,
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
            const Text(
              "Add Category",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: "Category Name",
                floatingLabelStyle: const TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  final categoryName = categoryController.text.trim();
                  if (categoryName.isNotEmpty) {
                    _addCategory(categoryName);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
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
        automaticallyImplyLeading: false,
        title: const Text(
          "Category Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.white,
      body: categories.isEmpty
          ? const Center(child: Text("No categories available."))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: ListTile(
                    title: Text(category['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(category['id']),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.black.withOpacity(0.1),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RecipeManagementScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CategoryManagementScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserManagementScreen()),
              );
            }
          },
          items: [
            CrystalNavigationBarItem(
              icon: IconlyBold.home,
              unselectedIcon: IconlyLight.home,
              selectedColor: Colors.orangeAccent,
            ),
            CrystalNavigationBarItem(
              icon: IconlyBold.paper,
              unselectedIcon: IconlyLight.paper,
              selectedColor: Colors.orangeAccent,
            ),
            CrystalNavigationBarItem(
              icon: IconlyBold.category,
              unselectedIcon: IconlyLight.category,
              selectedColor: Colors.orangeAccent,
            ),
            CrystalNavigationBarItem(
              icon: IconlyBold.user_2,
              unselectedIcon: IconlyLight.user_1,
              selectedColor: Colors.orangeAccent,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        onPressed: _showAddCategoryModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

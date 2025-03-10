import 'package:cookbuddy/screens/admin/category_management_screen.dart';
import 'package:cookbuddy/screens/admin/dashboard_screen.dart';
import 'package:cookbuddy/screens/admin/recipe_management_screen.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:iconly/iconly.dart';
import 'recipe_list_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<Map<String, dynamic>>> _userListFuture;

  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    setState(() {
      _userListFuture = DatabaseHelper.instance.getAllUsers();
    });
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await DatabaseHelper.instance.deleteUserAndRecipes(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User and associated recipes deleted.")),
      );
      _fetchUsers(); // Refresh the user list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "User Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No users found.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final userList = snapshot.data!;
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user['username'][0].toUpperCase()),
                ),
                title: Text(user['username']),
                subtitle: Text("Email: ${user['email']}"),
                onTap: () {
                  // Navigate to the Recipe List Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeListScreen(userId: user['id']),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete User"),
                        content: const Text(
                            "Are you sure you want to delete this user and their associated recipes?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteUser(user['id']);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedIndex,
          // indicatorColor: Colors.white,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.black.withOpacity(0.1),
          // outlineBorderColor: Colors.black.withOpacity(0.1),
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
            /// Home
            CrystalNavigationBarItem(
              icon: IconlyBold.home,
              unselectedIcon: IconlyLight.home,
              selectedColor: Colors.orangeAccent,
            ),

            /// Recipes Mgmt
            CrystalNavigationBarItem(
              icon: IconlyBold.paper,
              unselectedIcon: IconlyLight.paper,
              selectedColor: Colors.orangeAccent,
            ),

            /// Categories Sell
            CrystalNavigationBarItem(
              icon: IconlyBold.category,
              unselectedIcon: IconlyLight.category,
              selectedColor: Colors.orangeAccent,
            ),

            /// User mgmt
            CrystalNavigationBarItem(
                icon: IconlyBold.user_2,
                unselectedIcon: IconlyLight.user_1,
                selectedColor: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }
}

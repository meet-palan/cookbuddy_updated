import 'package:cookbuddy/screens/admin/admin_bottom_navbar.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import 'recipe_list_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<Map<String, dynamic>>> _userListFuture;

  int _selectedIndex = 3;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          title: Text(
            "User Management",
            style: GoogleFonts.lora(
                fontWeight: FontWeight.bold,
                color: AppColors.headingText,
                fontSize: 22),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appBar,
        ),
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _userListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "No users found.",
                    style: GoogleFonts.lora(
                        fontSize: 18, color: AppColors.headingText),
                  ),
                );
              }

              final userList = snapshot.data!;
              return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    final user = userList[index];
                    return Dismissible(
                      key: Key(
                          user['id'].toString()), // Unique key for each user
                      direction:
                          DismissDirection.endToStart, // Swipe left to delete
                      background: Container(
                        margin: const EdgeInsets.only(
                            bottom: 10.0), // Matches card spacing
                        decoration: BoxDecoration(
                          color: Colors
                              .red.shade400, // Softer red tone for better UX
                          borderRadius: BorderRadius.circular(
                              12), // Same rounded corners as card
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
                            Icon(Icons.delete, color: Colors.white, size: 28),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        bool? shouldDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete User"),
                            content: const Text(
                                "Are you sure you want to delete this user and their associated recipes?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                    context, false), // Cancel deletion
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(
                                    context, true), // Confirm deletion
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                        return shouldDelete; // Only delete if user confirms
                      },
                      onDismissed: (direction) {
                        _deleteUser(
                            user['id']); // Delete user only after confirmation
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        color: AppColors.background,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.hintText, width: 1),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user['username'][0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user['username'],
                            style: GoogleFonts.lora(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.headingText,
                            ),
                          ),
                          subtitle: Text(
                            "Email: ${user['email']}",
                            style: TextStyle(
                              color: AppColors.hintText,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeListScreen(userId: user['id']),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
        bottomNavigationBar: AdminBottomNavigationBar(
            currentIndex: _selectedIndex, onTap: _onNavItemTapped));
  }
}

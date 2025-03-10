import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';

class RecipeListScreen extends StatefulWidget {
  final int userId;

  const RecipeListScreen({super.key, required this.userId});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<Map<String, dynamic>>> _recipeListFuture;
  late Future<List<Map<String, dynamic>>> _userCommentsFuture;

  @override
  void initState() {
    super.initState();
    _recipeListFuture = _fetchUserRecipes();
    _userCommentsFuture = _fetchUserCommentsAndRatings();
  }

  Future<List<Map<String, dynamic>>> _fetchUserRecipes() async {
    return await DatabaseHelper.instance.getRecipesByUser(widget.userId);
  }

  Future<List<Map<String, dynamic>>> _fetchUserCommentsAndRatings() async {
    return await DatabaseHelper.instance
        .getCommentsAndRatingsByUser(widget.userId);
  }

  Future<String> _getCategoryName(int categoryId) async {
    return await DatabaseHelper.instance.getCategoryName(categoryId);
  }

  Future<void> _deleteRecipe(BuildContext context, int recipeId) async {
    await DatabaseHelper.instance.deleteRecipe(recipeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe deleted successfully.")),
    );
    setState(() {
      _recipeListFuture = _fetchUserRecipes();
    });
  }

  Future<void> _deleteComment(int commentId) async {
    await DatabaseHelper.instance.deleteComment(commentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        toolbarHeight: 60,
        title: Text("User Recipes and Feedback",
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.headingText,
            )),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recipeListFuture,
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
                      "No recipes found for this user.",
                      style: GoogleFonts.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingText),
                    ),
                  );
                }

                final recipeList = snapshot.data!;
                return ListView.builder(
                  itemCount: recipeList.length,
                  itemBuilder: (context, index) {
                    final recipe = recipeList[index];
                    return FutureBuilder<String>(
                      future: _getCategoryName(recipe['categoryId'] ?? 0),
                      builder: (context, categorySnapshot) {
                        final categoryName = categorySnapshot.data ??
                            'Unknown'; // Fallback to 'Unknown'

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: AppColors.enabledBorder.withOpacity(0.3),
                                width: 1),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Navigate to recipe detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    recipe: recipe,
                                    categoryName: categoryName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Align items vertically center
                                children: [
                                  // Recipe Image
                                  if (recipe['image'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        recipe[
                                            'image'], // Display image if available
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (recipe['image'] == null)
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.background
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant_menu,
                                        size: 40,
                                        color: AppColors.hintText,
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  // Recipe Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Recipe Name
                                        Text(
                                          recipe['name'] ??
                                              'Untitled Recipe', // Recipe name (null-safe)
                                          style: GoogleFonts.lora(
                                            fontSize: 18, // Increased font size
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.headingText,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Category Name
                                        Text(
                                          "Category: $categoryName", // Use category name here
                                          style: GoogleFonts.lora(
                                            fontSize: 16, // Increased font size
                                            color: AppColors.hintText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Uploaded By
                                        Text(
                                          "Uploaded by: ${recipe['insertedBy'] ?? 'Unknown'}", // Inserted by (admin/user)
                                          style: GoogleFonts.lora(
                                            fontSize: 14, // Increased font size
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.hintText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Delete Button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                      onPressed: () async {
                                        await _deleteRecipe(
                                            context, recipe['id']);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(
            thickness: 1,
            height: 20,
            color: AppColors.hintText,
          ),
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _userCommentsFuture,
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
                      "No comments or ratings found.",
                      style: GoogleFonts.lora(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                final comments = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];

                      return Dismissible(
                          key: Key(comment['id']
                              .toString()), // Unique key for each comment
                          direction: DismissDirection
                              .endToStart, // Right-to-left swipe
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: const Icon(Icons.delete,
                                color: Colors.white, size: 30),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Comment"),
                                  content: const Text(
                                      "Are you sure you want to delete this comment?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) async {
                            await _deleteComment(
                                comment['id']); // Delete function

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Comment deleted successfully.")),
                            );

                            setState(() {
                              _userCommentsFuture =
                                  _fetchUserCommentsAndRatings();
                            });
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            color: AppColors.background,
                            elevation: 2, // Improved shadow effect for depth
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  14), // Smooth rounded edges
                              side: BorderSide(
                                  color: AppColors.hintText.withOpacity(0.5),
                                  width: 0.8), // Softer border
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon with background
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withOpacity(
                                          0.1), // Subtle background
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(Icons.rate_review_rounded,
                                        color: Colors.blue, size: 28),
                                  ),

                                  const SizedBox(
                                      width: 14), // Space between icon and text

                                  // Comment & Rating section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Comment Text
                                        Text(
                                          comment['comment'] ?? 'No Comment',
                                          style: GoogleFonts.lora(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: AppColors.headingText,
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 6), // Adjusted spacing

                                        // Rating Row
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber,
                                                size: 18), // Star icon
                                            const SizedBox(width: 6),
                                            Text(
                                              "${comment['rating'] ?? 'No Rating'}",
                                              style: GoogleFonts.lora(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.hintText
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String categoryName;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.appBar,
        title: Center(
          child: Text(
            recipe['name'] ?? 'Recipe Details',
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Name
              Text(
                recipe['name'] ?? 'Untitled Recipe',
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 12),
              // Category Name
              Text(
                "Category: $categoryName",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 20),
              // Ingredients Section
              Text(
                "Ingredients:",
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe['ingredients'] ?? 'No ingredients provided.',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 20),
              // Instructions Section
              Text(
                "Instructions:",
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe['instructions'] ?? 'No instructions provided.',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }
}

import 'dart:typed_data';
import 'package:cookbuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cookbuddy/database/database_helper.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  Map<String, dynamic> _recipeDetails = {};
  List<Map<String, dynamic>> _commentsAndRatings = [];
  double _averageRating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;
  String _categoryName = "N/A";
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
    _loadCommentsAndRatings();
    _checkFavoriteStatus();
  }

  Future<void> _loadRecipeDetails() async {
    final recipe = await _databaseHelper.getRecipeDetails(widget.recipeId);
    if (recipe != null) {
      String categoryName = "N/A";
      if (recipe['categoryId'] != null) {
        categoryName =
            await _databaseHelper.getCategoryName(recipe['categoryId']);
      }
      setState(() {
        _recipeDetails = recipe;
        _categoryName = categoryName;
      });
    }
  }

  Future<void> _loadCommentsAndRatings() async {
    final comments =
        await _databaseHelper.getCommentsAndRatings(widget.recipeId);
    double avgRating = 0.0;

    if (comments.isNotEmpty) {
      avgRating =
          comments.map((e) => e['rating'] as int).reduce((a, b) => a + b) /
              comments.length;
    }

    setState(() {
      _commentsAndRatings = comments;
      _averageRating = avgRating;
    });
  }

  Future<void> _checkFavoriteStatus() async {
    bool isFavorite = await _databaseHelper.isRecipeFavorite(widget.recipeId);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    await _databaseHelper.toggleFavorite(widget.recipeId, !_isFavorite);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite
            ? "Recipe added to favorites!"
            : "Recipe removed from favorites!"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _submitCommentAndRating() async {
    if (_commentController.text.isEmpty || _selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide both a comment and a rating."),
          backgroundColor: AppColors.errorText,
        ),
      );
      return;
    }

    final commentData = {
      'recipeId': widget.recipeId,
      'userId': 1,
      'comment': _commentController.text,
      'rating': _selectedRating,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _databaseHelper.addCommentAndRating(commentData);

    _commentController.clear();
    _selectedRating = 0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Comment and rating submitted successfully."),
        backgroundColor: AppColors.primary,
      ),
    );

    _loadCommentsAndRatings();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? recipeImage = _recipeDetails['image'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        toolbarHeight: 60,
        title: Center(
          child: Text(
            _recipeDetails['name'] ?? "Recipe Details",
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.headingText,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: AppColors.headingText,
            ),
            onPressed: () {
              Share.share('Check out this recipe: ${_recipeDetails['name']}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipeImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.memory(
                    recipeImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _recipeDetails['name'] ?? "",
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${_averageRating.toStringAsFixed(1)} ⭐",
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Category: $_categoryName",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  color: AppColors.hintText,
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Ingredients:"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _recipeDetails['ingredients'] ?? "",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    color: AppColors.headingText,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Instructions:"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _recipeDetails['instructions'] ?? "",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    color: AppColors.headingText,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Comments & Ratings:"),
              const SizedBox(height: 8),
              ..._commentsAndRatings.map((comment) {
                String formattedTime = DateFormat('dd-MM-yyyy HH:mm').format(
                  DateTime.parse(comment['timestamp']),
                );
                return Card(
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: AppColors.hintText,
                      width: 1.0,
                    ),
                  ),
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['comment'] ?? "",
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.headingText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Rating: ${comment['rating']}/5",
                              style: GoogleFonts.lora(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.appBar,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formattedTime,
                              style: GoogleFonts.lora(
                                fontSize: 14,
                                color: AppColors.hintText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Add Your Comment:"),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Enter your comment",
                  hintStyle: GoogleFonts.lora(color: AppColors.hintText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColors.enabledBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColors.focusedBorder),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: _selectedRating > index
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitCommentAndRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.background,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.headingText,
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';

class EditRecipeScreen extends StatefulWidget {
  final int recipeId;
  final String initialName;
  final String initialIngredients;
  final String initialInstructions;
  final String initialyoutubeLink;
  final String? initialTime;
  final Uint8List? initialImage;

  final Function(int, String, String, String, String, String?) onUpdateRecipe;

  const EditRecipeScreen({
    super.key,
    required this.recipeId,
    required this.initialName,
    required this.initialIngredients,
    required this.initialInstructions,
    required this.initialyoutubeLink,
    required this.initialTime,
    required this.initialImage,
    required this.onUpdateRecipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController nameController;
  late TextEditingController ingredientsController;
  late TextEditingController instructionsController;
  late TextEditingController youtubeLinkController;
  late TextEditingController timeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    ingredientsController = TextEditingController(text: widget.initialIngredients);
    instructionsController = TextEditingController(text: widget.initialInstructions);
    youtubeLinkController = TextEditingController(text: widget.initialyoutubeLink);
    timeController = TextEditingController(text: widget.initialTime ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    ingredientsController.dispose();
    instructionsController.dispose();
    youtubeLinkController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onUpdateRecipe(
      widget.recipeId,
      nameController.text,
      ingredientsController.text,
      instructionsController.text,
      youtubeLinkController.text,
      timeController.text.isEmpty ? null : timeController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Recipe",
          style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
              fontSize: 22),
        ),
        backgroundColor: AppColors.appBar,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Recipe Name'),
            ),
            TextField(
              controller: ingredientsController,
              decoration: const InputDecoration(labelText: 'Ingredients'),
              maxLines: 3,
            ),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(labelText: 'Instructions'),
              maxLines: 5,
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

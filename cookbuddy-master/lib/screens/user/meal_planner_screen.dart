import 'package:cookbuddy/screens/user/favorites_screen.dart';
import 'package:cookbuddy/screens/user/home_screen.dart';
import 'package:cookbuddy/screens/user/my_recipes_screen.dart';
import 'package:cookbuddy/screens/user/recipe_selling_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlannerScreen extends StatefulWidget {
  final String userEmail;
  MealPlannerScreen({required this.userEmail});

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final _breakfastController = TextEditingController();
  final _lunchController = TextEditingController();
  final _dinnerController = TextEditingController();

  final _breakfastFocus = FocusNode();
  final _lunchFocus = FocusNode();
  final _dinnerFocus = FocusNode();

  int _currentIndex = 3;
  bool _loading = false;
  String _shoppingListText = "";

  int _generationCount = 0;
  final int _maxGenerations = 2;

  @override
  void initState() {
    super.initState();

    _breakfastFocus.addListener(() => setState(() {}));
    _lunchFocus.addListener(() => setState(() {}));
    _dinnerFocus.addListener(() => setState(() {}));

    checkInternetOnStart();
    loadGenerationCount();
  }

  Future<void> loadGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _generationCount = prefs.getInt('generation_count_${widget.userEmail}') ?? 0;
    });
  }

  Future<void> checkInternetOnStart() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No internet connection. Some features may not work."),
            backgroundColor: Colors.redAccent,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _breakfastFocus.dispose();
    _lunchFocus.dispose();
    _dinnerFocus.dispose();
    super.dispose();
  }

  Future<void> generateShoppingList() async {
    if (_generationCount >= _maxGenerations) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Limit reached. You can only generate the shopping list 2 times."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final breakfast = _breakfastController.text.trim();
    final lunch = _lunchController.text.trim();
    final dinner = _dinnerController.text.trim();

    if (breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter at least one meal.")),
      );
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No internet connection.")),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final prompt = '''
Create a shopping list to prepare the following meals:
Breakfast: $breakfast
Lunch: $lunch
Dinner: $dinner
Group ingredients by meal with clear headings.
''';

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyBsuxiz_GZMHdvn6XW7MYOQwvzo9x1Rsoo",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    String result = "Failed to generate shopping list.";
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      result = data["candidates"]?[0]["content"]["parts"][0]["text"] ?? result;
      _shoppingListText = result;
    }

    setState(() {
      _loading = false;
      _generationCount++;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('generation_count_${widget.userEmail}', _generationCount);

    showDialog(
      context: context,
      builder: (context) {
        final formattedList = formatShoppingList(_shoppingListText);
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text("Shopping List", style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: AppColors.headingText)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: formattedList,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(_shoppingListText);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  List<Widget> formatShoppingList(String rawText) {
    final lines = rawText.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      line = line.replaceAll('', '').replaceAll('*', '').trim();

      if (!line.startsWith('-') && !line.startsWith('•')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
            child: Text(
              line,
              style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: AppColors.headingText),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Expanded(child: Text(line.replaceFirst(RegExp(r'^[-•]'), '').trim())),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserHomeScreen(userEmail: widget.userEmail)));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyRecipesScreen(userEmail: widget.userEmail)));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeSellingPage(currentUserEmail: widget.userEmail)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => MealPlannerScreen(userEmail: widget.userEmail)));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteScreen(userEmail: widget.userEmail)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.appBar,
        title: Text(
          "Generate Shopping List",
          style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
              fontSize: 22),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildInputField("Breakfast", _breakfastController, _breakfastFocus),
            SizedBox(height: 10),
            buildInputField("Lunch", _lunchController, _lunchFocus),
            SizedBox(height: 10),
            buildInputField("Dinner", _dinnerController, _dinnerFocus),
            SizedBox(height: 10),
            /*Text(
              "Remaining uses: ${_maxGenerations - _generationCount}",
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),*/
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : generateShoppingList,
              icon: Icon(Icons.auto_awesome, color: AppColors.buttonText), // Changed icon here
              label: _loading
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                "Generate",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  color: AppColors.buttonText,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller, FocusNode focusNode) {
    final isFocused = focusNode.hasFocus;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: Colors.orange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isFocused ? Colors.orange : AppColors.headingText),
        prefixIcon: Icon(Icons.restaurant_menu, color: isFocused ? Colors.orange : AppColors.headingText),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.headingText),
        ),
      ),
    );
  }
}
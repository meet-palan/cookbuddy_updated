import 'package:cookbuddy/screens/user/favorites_screen.dart';
import 'package:cookbuddy/screens/user/home_screen.dart';
import 'package:cookbuddy/screens/user/my_recipes_screen.dart';
import 'package:cookbuddy/screens/user/recipe_selling_screen.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:cookbuddy/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:table_calendar/table_calendar.dart';

class MealPlannerScreen extends StatefulWidget {
  final String userEmail;
  const MealPlannerScreen({super.key, required this.userEmail});

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  // DateTime _focusedDay = DateTime.now();
  // DateTime _selectedDay = DateTime.now();
  // final Map<DateTime, Map<String, String>> _mealPlan = {};
  // final _mealSlots = ["Breakfast", "Lunch", "Dinner", "Snacks"];
  // final Map<String, TextEditingController> _controllers = {};

  int _currentIndex = 3;

  // @override
  // void dispose() {
  //   for (var controller in _controllers.values) {
  //     controller.dispose();
  //   }
  //   super.dispose();
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.appBar,
        title: Text(
          "Meal Planner",
          style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
              fontSize: 22),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Coming Soon',
          style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.headingText),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  // TextEditingController _getController(String slot) {
  //   _controllers.putIfAbsent(slot, () {
  //     String initialText = _mealPlan[_selectedDay]?[slot] ?? "";
  //     return TextEditingController(text: initialText);
  //   });
  //   return _controllers[slot]!;
  // }

  // void _showCalendarModal(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         height: 400,
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           children: [
  //             Text(
  //               "Select a Date",
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             Expanded(
  //               child: TableCalendar(
  //                 firstDay: DateTime(2020),
  //                 lastDay: DateTime(2050),
  //                 focusedDay: _focusedDay,
  //                 selectedDayPredicate: (day) {
  //                   return isSameDay(_selectedDay, day);
  //                 },
  //                 onDaySelected: (selectedDay, focusedDay) {
  //                   setState(() {
  //                     _selectedDay = selectedDay;
  //                     _focusedDay = focusedDay;
  //                   });
  //                   Navigator.pop(context); // Close modal on selection
  //                 },
  //                 calendarStyle: CalendarStyle(
  //                   selectedDecoration: BoxDecoration(
  //                     color: Colors.orange,
  //                     shape: BoxShape.circle,
  //                   ),
  //                   todayDecoration: BoxDecoration(
  //                     color: Colors.orange.shade200,
  //                     shape: BoxShape.circle,
  //                   ),
  //                   defaultDecoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //                 headerStyle: HeaderStyle(
  //                   formatButtonVisible: false,
  //                   titleCentered: true,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _generateShoppingListUsingAI() {
  //   List<String> shoppingList = [];
  //   _mealPlan[_selectedDay]?.values.forEach((meal) {
  //     shoppingList.addAll(meal.split(", ").map((item) => item.trim()));
  //   });
  //   shoppingList = shoppingList.toSet().toList(); // Remove duplicates

  //   Map<String, List<String>> categorizedList = {
  //     "Dairy": [],
  //     "Vegetables": [],
  //     "Protein": [],
  //     "Grains": [],
  //     "Others": []
  //   };

  //   for (var item in shoppingList) {
  //     if (["milk", "cheese", "butter", "yogurt"].contains(item.toLowerCase())) {
  //       categorizedList["Dairy"]!.add(item);
  //     } else if (["carrot", "spinach", "potato", "tomato"]
  //         .contains(item.toLowerCase())) {
  //       categorizedList["Vegetables"]!.add(item);
  //     } else if (["chicken", "egg", "fish", "tofu"]
  //         .contains(item.toLowerCase())) {
  //       categorizedList["Protein"]!.add(item);
  //     } else if (["rice", "bread", "pasta", "oats"]
  //         .contains(item.toLowerCase())) {
  //       categorizedList["Grains"]!.add(item);
  //     } else {
  //       categorizedList["Others"]!.add(item);
  //     }
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("AI-Generated Shopping List"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: categorizedList.entries
  //               .where((entry) => entry.value.isNotEmpty)
  //               .map((entry) {
  //             return Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   entry.key,
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 ...entry.value.map((item) => Text("- $item")),
  //                 SizedBox(height: 8),
  //               ],
  //             );
  //           }).toList(),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text("Close"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

// Meal Slot Widget
// class MealSlotWidget extends StatelessWidget {
//   final String slot;
//   final TextEditingController controller;
//   final Function(String) onMealChanged;

//   const MealSlotWidget({
//     super.key,
//     required this.slot,
//     required this.controller,
//     required this.onMealChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       color: Color(0xFFFFF3E0), // Light Peach background
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(16),
//         constraints: BoxConstraints(minHeight: 160),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               slot,
//               style: GoogleFonts.lora(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: AppColors.headingText, // Dark Brown
//               ),
//             ),
//             SizedBox(height: 12),
//             TextField(
//               controller: controller,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: "Enter meals (e.g., Eggs, Milk, Bread)",
//                 hintStyle:
//                     GoogleFonts.lora(color: AppColors.hintText), // Muted Brown
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide:
//                       BorderSide(color: AppColors.enabledBorder), // Light Brown
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                       color: AppColors.enabledBorder,
//                       width: 2), // Orange Accent
//                 ),
//                 filled: true,
//                 fillColor: Color(0xFFFFE0B2), // Soft orange shade
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//               ),
//               onChanged: onMealChanged,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cookbuddy/utils/colors.dart';
import 'package:cookbuddy/screens/admin/dashboard_screen.dart';
import 'package:cookbuddy/screens/admin/recipe_management_screen.dart';
import 'package:cookbuddy/screens/admin/category_management_screen.dart';
import 'package:cookbuddy/screens/admin/user_management_screen.dart';

class AdminBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      notchMargin: 8.0,
      color: AppColors.appBar,
      elevation: 15,
      child: NavigationBar(
        key: ValueKey<int>(currentIndex),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index != currentIndex) {
            onTap(index);
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RecipeManagementScreen()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoryManagementScreen()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserManagementScreen()),
                );
                break;
            }
          }
        },
        backgroundColor: AppColors.appBar,
        indicatorColor: AppColors.background,
        elevation: 5,
        height: 70,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: AppColors.background,
            width: 4,
          ),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined,
                size: 30, color: AppColors.background),
            selectedIcon:
                Icon(Icons.home, color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined,
                size: 30, color: AppColors.background),
            selectedIcon: Icon(Icons.receipt_long,
                color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined,
                size: 30, color: AppColors.background),
            selectedIcon:
                Icon(Icons.category, color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline,
                size: 30, color: AppColors.background),
            selectedIcon:
                Icon(Icons.people, color: AppColors.headingText, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}

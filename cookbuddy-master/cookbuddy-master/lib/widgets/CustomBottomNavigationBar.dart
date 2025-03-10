import 'package:cookbuddy/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
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
            // Prevent unnecessary rebuilds
            onTap(index);
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
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined,
                size: 30, color: AppColors.background),
            selectedIcon:
                Icon(Icons.home, color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined,
                color: AppColors.background, size: 30),
            selectedIcon: Icon(Icons.travel_explore,
                color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border,
                size: 30, color: AppColors.background),
            selectedIcon:
                Icon(Icons.favorite, color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined,
                size: 30, color: AppColors.background),
            selectedIcon: Icon(Icons.calendar_month_rounded,
                color: AppColors.headingText, size: 30),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline,
                size: 30, color: AppColors.background),
            selectedIcon:
                Icon(Icons.person, color: AppColors.headingText, size: 30),
            label: '',
          ),
        ],
      ),
    );
  }
}

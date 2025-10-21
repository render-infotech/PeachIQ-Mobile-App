import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color? backgroundColor;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        selectedIconTheme: IconThemeData(
          size: 34,
          weight: 350.0,
          color: selectedItemColor,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
          weight: 180.0,
          color: unselectedItemColor,
        ),
        backgroundColor: backgroundColor,
        // --- FIX IS HERE ---
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: 'Manrope',
          fontSize: 12, // Reduced from 14
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: 'Manrope',
          fontSize: 10, // Reduced from 14
        ),
        // --- END OF FIX ---
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            label: 'CheckIn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: 'Profile',
          ),
        ],
        onTap: onTap,
      ),
    );
  }
}
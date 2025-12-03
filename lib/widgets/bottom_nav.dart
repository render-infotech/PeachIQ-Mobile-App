import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color? backgroundColor;
  final int notificationCount;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.backgroundColor,
    this.notificationCount = 0,
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
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11.5,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontFamily: 'NunitoSans',
          color: Colors.white,
          inherit: false,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontFamily: 'NunitoSans',
          color: Colors.white,
          inherit: false,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            label: 'CheckIn',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                if (notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 12,
                      ),
                      child: Text(
                        notificationCount > 99 ? '99+' : notificationCount.toString(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              offset: const Offset(1.0, 1.0),
                              blurRadius: 2.0,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: 'Profile',
          ),
        ],
        onTap: onTap,
      ),
    );
  }
}
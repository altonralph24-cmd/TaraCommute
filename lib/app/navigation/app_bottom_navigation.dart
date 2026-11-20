
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../icons/app_icons.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.navigationBar,
      selectedItemColor: AppColors.navigationSelected,
      unselectedItemColor: AppColors.navigationUnselected,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(AppIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.commute),
          label: 'Commute',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.nearby),
          label: 'Nearby',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.terminals),
          label: 'Terminals',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.advisories),
          label: 'Advisories',
        ),
      ],
    );
  }
}

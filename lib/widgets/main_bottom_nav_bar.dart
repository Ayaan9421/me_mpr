import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MainBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar(
      icons: const [
        Icons.home_rounded,
        Icons.book_rounded,
        Icons.call_rounded,
        Icons.healing_rounded,
      ],
      activeIndex: selectedIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: onItemTapped,
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveColor: Colors.grey,
      backgroundColor: Colors.white,
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
      ),
    );
  }
}

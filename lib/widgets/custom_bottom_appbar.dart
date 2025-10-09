import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavIcon(icon: Icons.home_filled, index: 0, context: context),
          _buildNavIcon(icon: Icons.book_outlined, index: 1, context: context),
          const SizedBox(width: 48), // The space for the FAB
          _buildNavIcon(icon: Icons.call_outlined, index: 2, context: context),
          _buildNavIcon(icon: Icons.sos_outlined, index: 3, context: context),
        ],
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : AppColors.secondaryText;
    return IconButton(
      icon: Icon(icon, color: color, size: isSelected ? 30 : 28),
      onPressed: () => onItemTapped(index),
    );
  }
}

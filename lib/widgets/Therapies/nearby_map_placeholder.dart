import 'package:flutter/material.dart';
import 'package:me_mpr/utils/app_colors.dart';

class NearbyMapPlaceholder extends StatelessWidget {
  const NearbyMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 40,
                color: AppColors.secondaryText.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Map of Nearby Therapists (Placeholder)',
                style: TextStyle(
                  color: AppColors.secondaryText.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Requires location permissions & map setup',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

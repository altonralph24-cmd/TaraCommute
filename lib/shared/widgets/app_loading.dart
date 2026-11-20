
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message = 'Please wait...',
    this.size = 32,
  });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class Buttons extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final IconData? icon;
  final bool isPrimary;
  final bool isOutlined;
  final bool isSmall;
  
  const Buttons({
    super.key,
    required this.onPressed, 
    this.label,
    this.icon,
    this.isPrimary = true,
    this.isOutlined = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isPrimary ? AppColors.primary : AppColors.error,
          side: BorderSide(
            color: isPrimary ? AppColors.primary : AppColors.error,
            width: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 24,
            vertical: isSmall ? 10 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: isSmall ? 18 : 20),
              const SizedBox(width: 8),
            ],
            Text(
              label ?? '',
              style: (isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button).copyWith(
                color: isPrimary ? AppColors.primary : AppColors.error,
              ),
            ),
          ],
        ),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : AppColors.error,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 24,
          vertical: isSmall ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 18 : 20),
            const SizedBox(width: 8),
          ],
          Text(
            label ?? '',
            style: isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button,
          ),
        ],
      ),
    );
  }
}
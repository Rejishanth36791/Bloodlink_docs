import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant { primary, success, dangerOutline, secondary, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.primaryMain;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case ButtonVariant.success:
        bg = AppColors.lifeGreen;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case ButtonVariant.dangerOutline:
        bg = AppColors.surfaceWhite;
        fg = AppColors.criticalRed;
        border = const BorderSide(color: AppColors.criticalRed, width: 1.2);
        break;
      case ButtonVariant.secondary:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryDark;
        border = BorderSide.none;
        break;
      case ButtonVariant.outline:
        bg = AppColors.surfaceWhite;
        fg = AppColors.textHeadline;
        border = const BorderSide(color: AppColors.borderLight, width: 1);
        break;
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTextStyles.button.copyWith(color: fg),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

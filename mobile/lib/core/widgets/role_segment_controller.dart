import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RoleSegmentController extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onRoleChanged;
  final String firstLabel;
  final String secondLabel;
  final IconData firstIcon;
  final IconData secondIcon;

  const RoleSegmentController({
    super.key,
    required this.selectedIndex,
    required this.onRoleChanged,
    this.firstLabel = 'Donor Portal',
    this.secondLabel = 'Requester Portal',
    this.firstIcon = Icons.favorite_rounded,
    this.secondIcon = Icons.volunteer_activism_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              index: 0,
              label: firstLabel,
              icon: firstIcon,
            ),
          ),
          Expanded(
            child: _buildSegment(
              index: 1,
              label: secondLabel,
              icon: secondIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onRoleChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMain : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryMain.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? Colors.white : AppColors.primaryDark,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

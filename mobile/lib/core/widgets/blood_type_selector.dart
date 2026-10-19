import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BloodTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onSelected;
  final bool showHelperNote;

  const BloodTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
    this.showHelperNote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 24) / 4;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.bloodTypes.map((type) {
                final isSelected = selectedType == type;
                return SizedBox(
                  width: itemWidth,
                  height: 48,
                  child: InkWell(
                    onTap: () => onSelected(type),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryMain : AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryMain : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primaryMain.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        type,
                        style: AppTextStyles.titleSm.copyWith(
                          color: isSelected ? Colors.white : AppColors.textHeadline,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (showHelperNote && selectedType != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.aiIntelligence),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  selectedType == 'O-'
                      ? 'O- is the Universal Donor type (compatible with all recipients).'
                      : selectedType == 'AB+'
                          ? 'AB+ is the Universal Recipient type (can receive all blood types).'
                          : 'Compatible matching active for $selectedType.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

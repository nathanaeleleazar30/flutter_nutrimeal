import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class NutriMealLogo extends StatelessWidget {
  final double fontSize;
  final bool hasShadow;

  const NutriMealLogo({
    super.key,
    this.fontSize = 32,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final double pillVerticalPadding = fontSize * 0.08;
    final double pillHorizontalPadding = fontSize * 0.36;
    final double pillRadius = fontSize * 0.52;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Nutri',
          style: AppTextStyles.logoNutri(fontSize: fontSize),
        ),
        SizedBox(width: fontSize * 0.12),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: pillHorizontalPadding,
            vertical: pillVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.pillBlack,
            borderRadius: BorderRadius.circular(pillRadius),
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: fontSize * 0.35,
                      offset: Offset(0, fontSize * 0.14),
                    ),
                  ]
                : null,
          ),
          child: Text(
            'Meal',
            style: AppTextStyles.logoMeal(fontSize: fontSize),
          ),
        ),
      ],
    );
  }
}

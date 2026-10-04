import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enablePasswordToggle;
  final String? errorText;
  final Widget? prefixWidget;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.enablePasswordToggle = false,
    this.errorText,
    this.prefixWidget,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasError
                ? AppColors.errorBackground
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.errorBorder : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefixWidget != null) widget.prefixWidget!,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: _obscured,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: AppTextStyles.inputText,
                    cursorColor: AppColors.primaryGreen,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: AppTextStyles.inputHint,
                      suffixIcon: widget.enablePasswordToggle && widget.obscureText
                          ? IconButton(
                              icon: Icon(
                                _obscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscured = !_obscured;
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.errorText,
            ),
          ),
        ],
      ],
    );
  }
}

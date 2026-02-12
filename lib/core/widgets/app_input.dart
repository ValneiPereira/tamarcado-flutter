import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? error;
  final String? hintText;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onRightIconPress;
  final bool obscureText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final bool enabled;

  const AppInput({
    super.key,
    this.label,
    this.error,
    this.hintText,
    this.leftIcon,
    this.rightIcon,
    this.onRightIconPress,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.enabled = true,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: AppTypography.sm,
                fontWeight: AppTypography.medium,
                color: AppColors.text,
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onEditingComplete: widget.onEditingComplete,
          enabled: widget.enabled,
          style: const TextStyle(
            fontSize: AppTypography.base,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: AppColors.textLight),
            errorText: widget.error,
            prefixIcon: widget.leftIcon != null
                ? Icon(widget.leftIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: _buildSuffixIcon(),
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () => setState(() => _isObscured = !_isObscured),
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
      );
    }
    if (widget.rightIcon != null) {
      return IconButton(
        onPressed: widget.onRightIconPress,
        icon: Icon(
          widget.rightIcon,
          size: 20,
          color: AppColors.textSecondary,
        ),
      );
    }
    return null;
  }
}

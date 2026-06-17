import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_sizes.dart';
import '../theme/app_style.dart';

class MyAppTextfield extends StatelessWidget {
  const MyAppTextfield({
    super.key,
    required this.label,
    this.showLabel = true,
    this.controller,
    this.initialValue,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.prefixIcon,
    this.onChanged,
    this.inputFormatters,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.errorText,
    this.onSuffixIconTap,
  });

  final String label;
  final bool showLabel;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final String? errorText;
   final VoidCallback? onSuffixIconTap;
   final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final bool isInactive = readOnly || !enabled;
    final Color backgroundColor = isInactive
        ? const Color(0xFFF1F1F5)
        : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(label, style: AppTypography.medium14(color: Colors.black87)),
          AppSizes.gapH8,
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          inputFormatters: inputFormatters ?? [],
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            errorText: errorText,
            fillColor: backgroundColor, 
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    color: Colors.grey.shade500,
                    size: AppSizes.iconSizeTiny,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(
                  0xFF2D9CDB,
                ), 
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.4),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: onSuffixIconTap,
                  ),
          ),
        ),
      ],
    );
  }
}

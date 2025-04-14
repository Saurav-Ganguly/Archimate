import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom text field widget with consistent styling
class CustomTextField extends StatelessWidget {
  /// Creates a new [CustomTextField] instance
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  /// Text editing controller
  final TextEditingController controller;
  
  /// Label text for the field
  final String? labelText;
  
  /// Hint text for the field
  final String? hintText;
  
  /// Optional icon to display at the start of the field
  final IconData? prefixIcon;
  
  /// Optional widget to display at the end of the field
  final Widget? suffixIcon;
  
  /// Whether to obscure the text (for passwords)
  final bool obscureText;
  
  /// Keyboard type for the field
  final TextInputType? keyboardType;
  
  /// Text input action for the field
  final TextInputAction? textInputAction;
  
  /// Validator function for form validation
  final String? Function(String?)? validator;
  
  /// Callback when text changes
  final void Function(String)? onChanged;
  
  /// Callback when field is submitted
  final void Function(String)? onSubmitted;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Maximum number of lines (for multiline fields)
  final int? maxLines;
  
  /// Minimum number of lines (for multiline fields)
  final int? minLines;
  
  /// Maximum length of text
  final int? maxLength;
  
  /// Input formatters for restricting input
  final List<TextInputFormatter>? inputFormatters;
  
  /// Whether to focus this field automatically
  final bool autofocus;
  
  /// Whether the field is read-only
  final bool readOnly;
  
  /// Callback when the field is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: theme.textTheme.bodyLarge,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}

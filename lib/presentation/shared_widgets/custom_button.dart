import 'package:flutter/material.dart';

/// A custom button widget with loading state support
class CustomButton extends StatelessWidget {
  /// Creates a new [CustomButton] instance
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 50,
    this.borderRadius = 8,
    this.isOutlined = false,
  });

  /// The text to display on the button
  final String text;
  
  /// Callback when the button is pressed
  final VoidCallback onPressed;
  
  /// Whether the button is in loading state
  final bool isLoading;
  
  /// Optional background color, uses theme primary color if not provided
  final Color? backgroundColor;
  
  /// Optional text color, uses theme onPrimary color if not provided
  final Color? textColor;
  
  /// Optional icon to display before the text
  final IconData? icon;
  
  /// Optional button width, defaults to full width
  final double? width;
  
  /// Button height
  final double height;
  
  /// Border radius of the button
  final double borderRadius;
  
  /// Whether to show an outlined button instead of filled
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: backgroundColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: backgroundColor ?? theme.colorScheme.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: Size(width ?? double.infinity, height),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: textColor ?? theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: Size(width ?? double.infinity, height),
          );

    final buttonChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined
                  ? backgroundColor ?? theme.colorScheme.primary
                  : textColor ?? theme.colorScheme.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOutlined
                      ? backgroundColor ?? theme.colorScheme.primary
                      : textColor ?? theme.colorScheme.onPrimary,
                ),
              ),
            ],
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          );
  }
}

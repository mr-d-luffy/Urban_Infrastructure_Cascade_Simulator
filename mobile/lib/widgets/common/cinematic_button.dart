import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

enum CinematicButtonStyle { primary, secondary, success, danger, outline }

class CinematicButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final CinematicButtonStyle style;
  final bool isLoading;
  final double fontSize;
  final EdgeInsets padding;

  const CinematicButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = CinematicButtonStyle.primary,
    this.isLoading = false,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (style) {
      case CinematicButtonStyle.primary:
        bg = isDark ? AppTheme.pureWhite : AppTheme.primaryNavy;
        fg = isDark ? AppTheme.primaryNavy : AppTheme.pureWhite;
        break;
      case CinematicButtonStyle.secondary:
        bg = isDark ? AppTheme.darkSurface : AppTheme.lightBackground;
        fg = isDark ? AppTheme.pureWhite : AppTheme.primaryNavy;
        border = BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder);
        break;
      case CinematicButtonStyle.success:
        bg = AppTheme.success.withValues(alpha: isDark ? 0.25 : 0.12);
        fg = isDark ? AppTheme.pureWhite : AppTheme.primaryNavy;
        border = BorderSide(color: AppTheme.success.withValues(alpha: 0.5));
        break;
      case CinematicButtonStyle.danger:
        bg = AppTheme.critical.withValues(alpha: isDark ? 0.25 : 0.12);
        fg = AppTheme.critical;
        border = BorderSide(color: AppTheme.critical.withValues(alpha: 0.5));
        break;
      case CinematicButtonStyle.outline:
        bg = Colors.transparent;
        fg = isDark ? AppTheme.pureWhite : AppTheme.primaryNavy;
        border = BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder);
        break;
    }

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        side: border,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: onPressed == null ? fg.withValues(alpha: 0.4) : fg,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(icon, size: fontSize + 2, color: onPressed == null ? fg.withValues(alpha: 0.4) : fg),
                ],
              ],
            ),
    );
  }
}

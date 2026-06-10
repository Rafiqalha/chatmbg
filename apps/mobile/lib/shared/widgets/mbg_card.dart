import 'package:flutter/material.dart';

import '../../app/theme/mbg_theme.dart';

/// Styled card with MBG design system border radius and colors.
class MbgCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final Border? border;

  const MbgCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? (isDark ? const Color(0xFF211F1B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: border ??
              Border.all(
                color: isDark ? MBGColors.neutral200.withValues(alpha: 0.12) : MBGColors.neutral200,
              ),
        ),
        child: child,
      ),
    );
  }
}

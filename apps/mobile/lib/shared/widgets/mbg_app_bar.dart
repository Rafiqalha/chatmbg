import 'package:flutter/material.dart';

import '../../app/theme/mbg_theme.dart';

/// MBGBrain branded app bar with leaf icon.
class MbgAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  const MbgAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      leading: leading,
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset('assets/logo/logo-chatmbg.png', width: 28, height: 28),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    children: [
                      TextSpan(
                        text: 'MBG',
                        style: TextStyle(
                          color: isDark ? Colors.white : MBGColors.neutral900,
                        ),
                      ),
                      const TextSpan(
                        text: 'Brain',
                        style: TextStyle(color: MBGColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Text(title),
      actions: actions,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colorScheme.surface,
    );
  }
}

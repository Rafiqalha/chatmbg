import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/mbg_theme.dart';
import '../../features/auth/providers/auth_provider.dart';

class MbgSidebar extends ConsumerWidget {
  const MbgSidebar({super.key});

  void _onNavigate(BuildContext context, String path) {
    Navigator.pop(context);
    if (GoRouterState.of(context).matchedLocation != path) {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).matchedLocation;
    final email = auth.user?.email ?? 'Pengguna';
    final name =
        auth.user?.userMetadata?['full_name'] as String? ?? 'MBG User';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [MBGColors.primary, MBGColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 17,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/chat');
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Chat Baru'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: MBGColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _MenuItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: 'AI Assistant',
                    path: '/chat',
                    currentPath: currentPath,
                    onTap: () => _onNavigate(context, '/chat'),
                  ),
                  _MenuItem(
                    icon: Icons.restaurant_menu_outlined,
                    activeIcon: Icons.restaurant_menu_rounded,
                    label: 'Validator Menu',
                    path: '/validator',
                    currentPath: currentPath,
                    onTap: () => _onNavigate(context, '/validator'),
                  ),
                  _MenuItem(
                    icon: Icons.verified_user_outlined,
                    activeIcon: Icons.verified_user_rounded,
                    label: 'Kepatuhan SK 244',
                    path: '/compliance',
                    currentPath: currentPath,

                    onTap: () => _onNavigate(context, '/compliance'),
                  ),
                  _MenuItem(
                    icon: Icons.store_outlined,
                    activeIcon: Icons.store_rounded,
                    label: 'Direktori Supplier',
                    path: '/suppliers',
                    currentPath: currentPath,
                    onTap: () => _onNavigate(context, '/suppliers'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onNavigate(context, '/settings'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: currentPath == '/settings'
                          ? (isDark
                              ? Colors.white10
                              : MBGColors.neutral200.withValues(alpha: 0.5))
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              MBGColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: MBGColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                email,
                                style: TextStyle(
                                    color: MBGColors.neutral500, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: MBGColors.neutral500, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final String currentPath;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentPath == path;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isActive
                  ? (isDark
                      ? Colors.white12
                      : MBGColors.neutral200.withValues(alpha: 0.6))
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive
                      ? (isDark ? Colors.white : MBGColors.neutral900)
                      : MBGColors.neutral500,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? (isDark ? Colors.white : MBGColors.neutral900)
                        : (isDark ? Colors.white70 : MBGColors.neutral700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

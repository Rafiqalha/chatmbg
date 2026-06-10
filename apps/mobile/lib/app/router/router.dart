import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/compliance/screens/compliance_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/suppliers/screens/suppliers_screen.dart';
import '../../features/validator/screens/validator_screen.dart';
import '../../shared/widgets/mbg_sidebar.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/chat',
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    if (!loggedIn && !isAuthRoute) return '/login';
    if (loggedIn && isAuthRoute) return '/chat';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ChatScreen(),
          ),
        ),
        GoRoute(
          path: '/validator',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ValidatorScreen(),
          ),
        ),
        GoRoute(
          path: '/compliance',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ComplianceScreen(),
          ),
        ),
        GoRoute(
          path: '/suppliers',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const SuppliersScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _currentIndex(String location) {
    if (location.startsWith('/chat')) return 0;
    if (location.startsWith('/validator')) return 1;
    if (location.startsWith('/compliance')) return 2;
    if (location.startsWith('/suppliers')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      drawer: const MbgSidebar(),
      body: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Text(_titleFor(location)),
          actions: [
            if (location == '/chat')
              IconButton(
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: 'Chat Baru',
                onPressed: () {
                  context.pushReplacement('/chat');
                },
              ),
          ],
        ),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex(location),
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/chat');
              case 1:
                context.go('/validator');
              case 2:
                context.go('/compliance');
              case 3:
                context.go('/suppliers');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Validator',
            ),
            NavigationDestination(
              icon: Icon(Icons.verified_user_outlined),
              selectedIcon: Icon(Icons.verified_user_rounded),
              label: 'Kepatuhan',
            ),
            NavigationDestination(
              icon: Icon(Icons.store_outlined),
              selectedIcon: Icon(Icons.store_rounded),
              label: 'Supplier',
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(String location) {
    if (location.startsWith('/chat')) return 'MBGBrain';
    if (location.startsWith('/validator')) return 'Validator Menu';
    if (location.startsWith('/compliance')) return 'Cek Kepatuhan';
    if (location.startsWith('/suppliers')) return 'Direktori Supplier';
    if (location.startsWith('/settings')) return 'Pengaturan';
    return 'MBGBrain';
  }
}

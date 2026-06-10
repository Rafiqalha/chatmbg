import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbgbrain_mobile/app/router/router.dart';
import 'package:mbgbrain_mobile/app/theme/mbg_theme.dart';

class MBGApp extends ConsumerWidget {
  const MBGApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MBGBrain',
      theme: mbgLightTheme,
      darkTheme: mbgDarkTheme,
      themeMode: ThemeMode.system, // Switch based on device settings
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

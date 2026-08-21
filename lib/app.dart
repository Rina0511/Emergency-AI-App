import 'package:flutter/material.dart';

import 'app_settings_controller.dart';
import 'routes.dart';

class EmergencyAIApp extends StatelessWidget {
  const EmergencyAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Emergency AI App',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.languageSelection,
          routes: AppRoutes.map,
          themeMode: appSettingsController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFEAF1FB),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F6FE4),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0B1220),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F6FE4),
              brightness: Brightness.dark,
            ),
          ),
        );
      },
    );
  }
}

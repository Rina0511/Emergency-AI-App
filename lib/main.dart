import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_settings_controller.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';
import 'screens/splash/splash_screen.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await appSettingsController.loadSettings();

  await FcmService.initialize();

  runApp(const EmergencyAiApp());
}

class EmergencyAiApp extends StatelessWidget {
  const EmergencyAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettingsController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Emergency AI',
          locale: appSettingsController.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ms')],
          themeMode: appSettingsController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            fontFamily: null,
            scaffoldBackgroundColor: const Color(0xFFEAF1FB),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F6FE4),
              brightness: Brightness.light,
              primary: const Color(0xFF2F6FE4),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFEAF1FB),
              foregroundColor: Color(0xFF0B1B3A),
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            fontFamily: null,
            scaffoldBackgroundColor: const Color(0xFF0B1220),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F6FE4),
              brightness: Brightness.dark,
              primary: const Color(0xFF2F6FE4),
              surface: const Color(0xFF162033),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0B1220),
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF162033),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          home: const SplashScreen(),
          routes: AppRoutes.map,
        );
      },
    );
  }
}

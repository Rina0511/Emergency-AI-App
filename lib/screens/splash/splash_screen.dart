import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    final bool hasChosenLanguage = prefs.getBool('hasChosenLanguage') ?? false;
    final String? languageCode = prefs.getString('languageCode');

    debugPrint('Splash current user: ${user?.uid}');
    debugPrint('hasChosenLanguage: $hasChosenLanguage');
    debugPrint('languageCode: $languageCode');

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
      return;
    }

    if (!hasChosenLanguage && languageCode == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.languageSelection);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final bgBottom = isDark ? const Color(0xFF111A2E) : const Color(0xFFDCE8FA);

    final logoBg = isDark
        ? const Color(0xFF162033).withOpacity(0.96)
        : Colors.white.withOpacity(0.96);

    final textDark = isDark ? Colors.white : const Color(0xFF10264D);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF6F809A);

    const primaryBlue = Color(0xFF1E63D0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: logoBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 22,
                            color: Colors.black.withOpacity(
                              isDark ? 0.22 : 0.08,
                            ),
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Emergency AI App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart emergency help, faster response',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SizedBox(
                      height: 42,
                      width: 42,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

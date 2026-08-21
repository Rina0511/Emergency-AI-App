import 'package:flutter/material.dart';

import '../../app_settings_controller.dart';
import '../../routes.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en';
  bool _loading = false;

  Future<void> _selectLanguage(String code) async {
    setState(() => _selectedLanguage = code);
    await appSettingsController.changeLanguage(code);
  }

  Future<void> _continue() async {
    setState(() => _loading = true);

    await appSettingsController.changeLanguage(_selectedLanguage);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final logoBg = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark
        ? Colors.white70
        : Colors.black.withValues(alpha: 0.5);

    const primaryBlue = Color(0xFF1E63D0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: logoBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.20 : 0.08,
                        ),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.emergency_outlined,
                        color: Color(0xFF2F6FE4),
                        size: 48,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Choose Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your preferred language to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textSoft),
              ),
              const SizedBox(height: 32),
              _LanguageCard(
                title: 'English',
                subtitle: 'Use the app in English',
                selected: _selectedLanguage == 'en',
                onTap: () => _selectLanguage('en'),
              ),
              const SizedBox(height: 14),
              _LanguageCard(
                title: 'Bahasa Melayu',
                subtitle: 'Gunakan aplikasi dalam Bahasa Melayu',
                selected: _selectedLanguage == 'ms',
                onTap: () => _selectLanguage('ms'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  disabledBackgroundColor: primaryBlue.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark
        ? Colors.white70
        : Colors.black.withValues(alpha: 0.5);

    const primaryBlue = Color(0xFF2F6FE4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: primaryBlue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: textSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

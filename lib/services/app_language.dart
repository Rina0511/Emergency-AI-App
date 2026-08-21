import 'package:flutter/material.dart';

class AppLanguage {
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(
    const Locale('en'),
  );

  static void setLocale(String code) {
    localeNotifier.value = Locale(code);
  }

  static bool isMalay(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ms';
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('languageCode') ?? 'en';

      await AuthService.registerUser(
        name: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: '+60${_phoneCtrl.text.trim()}',
        password: _passwordCtrl.text.trim(),
        languageCode: languageCode,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await AuthService.updateUserExtra(uid, {
        'verified': false,
        'verificationMethod': 'not_required',
      });

      await FcmService.saveUserToken();
      await FcmService.startInAppNotificationListener();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountCreatedSuccessfully)));

      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = e.message ?? 'Registration failed';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'configuration-not-found') {
        message = 'Firebase Email/Password login is not enabled.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Register error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() => Navigator.pop(context);

  void _goSignIn() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final descColor = isDark ? Colors.white70 : Colors.black.withOpacity(0.50);

    final secureColor = isDark
        ? Colors.white54
        : Colors.black.withOpacity(0.35);

    final footerColor = isDark
        ? Colors.white60
        : Colors.black.withOpacity(0.45);

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _goBack,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textDark,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        l10n.createAccount,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.registerDesc,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: descColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                _RegisterField(
                  controller: _fullNameCtrl,
                  hintText: l10n.fullName,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return '${l10n.fullName} required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _RegisterField(
                  controller: _emailCtrl,
                  hintText: l10n.emailAddress,
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return l10n.emailRequired;
                    if (!v.contains('@')) return l10n.enterValidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _PhoneField(
                  controller: _phoneCtrl,
                  hintText: l10n.phoneNumber,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return l10n.phoneRequired;
                    if (v.length < 8) return l10n.enterValidPhone;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _RegisterField(
                  controller: _passwordCtrl,
                  hintText: l10n.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: textSoft,
                    ),
                  ),
                  validator: (value) {
                    final v = value ?? '';
                    if (v.isEmpty) return l10n.passwordRequired;
                    if (v.length < 6) return l10n.minimum6Characters;
                    return null;
                  },
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryBlue.withOpacity(0.55),
                      disabledForegroundColor: Colors.white70,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 21,
                            width: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.createAccount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                      color: secureColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.dataEncryptedSecure,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: secureColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '${l10n.alreadyHaveAccount} ',
                        style: TextStyle(
                          fontSize: 15,
                          color: footerColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _goSignIn,
                      child: Text(
                        l10n.signIn,
                        style: const TextStyle(
                          fontSize: 15,
                          color: primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _RegisterField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textSoft, fontWeight: FontWeight.w500),
        prefixIcon: Icon(prefixIcon, color: textSoft),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: primaryBlue.withOpacity(isDark ? 0.45 : 0.25),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const _PhoneField({
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputColor,
        hintText: hintText,
        hintStyle: TextStyle(color: textSoft, fontWeight: FontWeight.w500),
        prefixIcon: Container(
          width: 70,
          alignment: Alignment.center,
          child: Text(
            '+60',
            style: TextStyle(
              fontSize: 15,
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: primaryBlue.withOpacity(isDark ? 0.45 : 0.25),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

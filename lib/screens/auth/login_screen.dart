import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService.loginUser(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      await FcmService.saveUserToken();
      await FcmService.startInAppNotificationListener();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = e.message ?? 'Login failed';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _goEmergencyNow() {
    Navigator.pushNamed(context, AppRoutes.emergencyNow);
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first.')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset link has been sent to $email. Please check your email.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Failed to send password reset email.';

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      } else if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final bgBottom = isDark ? const Color(0xFF111A2E) : const Color(0xFFDEE9F8);

    final cardColor = isDark
        ? const Color(0xFF162033).withOpacity(0.92)
        : Colors.white.withOpacity(0.78);

    final logoBg = isDark
        ? const Color(0xFF162033).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    final textDark = isDark ? Colors.white : const Color(0xFF11254D);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF6E7F99);

    final smallTextColor = isDark ? Colors.white54 : Colors.black54;

    final extraSmallTextColor = isDark ? Colors.white38 : Colors.black45;

    const primaryBlue = Color(0xFF1E63D0);
    const dangerRed = Color(0xFFE53935);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        Center(
                          child: Container(
                            height: 138,
                            width: 138,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: logoBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 18,
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.22 : 0.08,
                                  ),
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 46,
                                  color: Color(0xFF0D47A1),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Text(
                          l10n.welcomeBack,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: textDark,
                              ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n.signInEmergencyApp,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: textSoft,
                                fontWeight: FontWeight.w500,
                              ),
                        ),

                        const SizedBox(height: 28),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _RoundedField(
                                  controller: _emailCtrl,
                                  label: l10n.emailAddress,
                                  icon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    final value = (v ?? '').trim();
                                    if (value.isEmpty) {
                                      return l10n.emailRequired;
                                    }
                                    if (!value.contains('@')) {
                                      return l10n.enterValidEmail;
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 14),

                                _RoundedField(
                                  controller: _passwordCtrl,
                                  label: l10n.password,
                                  icon: Icons.lock_outline,
                                  obscureText: _obscure,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() => _obscure = !_obscure);
                                    },
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  validator: (v) {
                                    final value = (v ?? '');
                                    if (value.isEmpty) {
                                      return l10n.passwordRequired;
                                    }
                                    if (value.length < 6) {
                                      return l10n.minimum6Characters;
                                    }
                                    return null;
                                  },
                                  onSubmitted: (_) => _signIn(),
                                ),

                                const SizedBox(height: 10),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _loading
                                        ? null
                                        : _forgotPassword,
                                    child: Text(l10n.forgotPassword),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: primaryBlue
                                          .withOpacity(0.55),
                                      disabledForegroundColor: Colors.white70,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 17,
                                      ),
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
                                        : Text(
                                            l10n.signIn,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${l10n.dontHaveAccount} ',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: smallTextColor),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _loading ? null : _goRegister,
                                      child: const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _goEmergencyNow,
                                    icon: const Icon(
                                      Icons.warning_amber_rounded,
                                    ),
                                    label: Text(
                                      l10n.emergencyNow,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: dangerRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 17,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 6,
                                      shadowColor: dangerRed.withOpacity(0.35),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  l10n.noLoginRequired,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: smallTextColor),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  l10n.emergencyModeNoLogin,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: extraSmallTextColor),
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 18,
                                      color: extraSmallTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        l10n.secureEncryptedAi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: extraSmallTextColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _RoundedField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final borderColor = isDark
        ? Colors.white12
        : Colors.black.withOpacity(0.08);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSoft),
        prefixIcon: Icon(icon, color: textSoft),
        suffixIcon: suffix,
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}

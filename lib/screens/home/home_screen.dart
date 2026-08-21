import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  String _userName = 'User';
  String _userEmail = '';
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _userName = 'Guest';
        _userEmail = '';
        _loadingUser = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      setState(() {
        _userName = (data?['name'] ?? user.email ?? 'User').toString();
        _userEmail = (data?['email'] ?? user.email ?? '').toString();
        _loadingUser = false;
      });
    } catch (_) {
      setState(() {
        _userName = user.email ?? 'User';
        _userEmail = user.email ?? '';
        _loadingUser = false;
      });
    }
  }

  Future<void> _call999Directly() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open phone dialer.')),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _greeting(AppLocalizations t) {
    if (_loadingUser) return t.homeTitle;
    return 'Hi, $_userName';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.emergency_outlined,
                          color: primaryBlue,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(t),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _userEmail.isEmpty ? t.locationActive : _userEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: textSoft,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TopIcon(
                    icon: Icons.notifications_none,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                  const SizedBox(width: 8),
                  _TopIcon(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                  const SizedBox(width: 8),
                  _TopIcon(icon: Icons.logout, onTap: _logout),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  height: 280,
                  width: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.9 + (_controller.value * 0.18),
                            child: Container(
                              height: 260,
                              width: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFFE12529,
                                ).withOpacity(isDark ? 0.14 : 0.08),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: 165,
                        width: 165,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE12529),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _call999Directly,
                          onLongPress: _call999Directly,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SOS',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tap: Emergency Now\nHold: Call 999',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  t.fastResponse,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.reportRole);
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.upload_outlined, color: primaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.uploadIncidentPhotoAI,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _HomeActionCard(
                title: 'Report Emergency Manually',
                subtitle:
                    'Create an emergency report without AI analysis when needed.',
                icon: Icons.edit_document,
                color: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.manualReport);
                },
              ),
              const SizedBox(height: 18),

              Text(
                t.emergencyCategories,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: [
                  _MiniCategory(
                    label: t.accident,
                    icon: Icons.directions_car_outlined,
                    description: t.accidentDesc,
                    points: [
                      t.accidentPoint1,
                      t.accidentPoint2,
                      t.accidentPoint3,
                      t.accidentPoint4,
                    ],
                  ),
                  _MiniCategory(
                    label: t.fire,
                    icon: Icons.local_fire_department_outlined,
                    description: t.fireDesc,
                    points: [
                      t.firePoint1,
                      t.firePoint2,
                      t.firePoint3,
                      t.firePoint4,
                    ],
                  ),
                  _MiniCategory(
                    label: t.medical,
                    icon: Icons.favorite_border,
                    description: t.medicalDesc,
                    points: [
                      t.medicalPoint1,
                      t.medicalPoint2,
                      t.medicalPoint3,
                      t.medicalPoint4,
                    ],
                  ),
                  _MiniCategory(
                    label: t.crime,
                    icon: Icons.shield_outlined,
                    description: t.crimeDesc,
                    points: [
                      t.crimePoint1,
                      t.crimePoint2,
                      t.crimePoint3,
                      t.crimePoint4,
                    ],
                  ),
                  _MiniCategory(
                    label: t.hazard,
                    icon: Icons.warning_amber_rounded,
                    description: t.hazardDesc,
                    points: [
                      t.hazardPoint1,
                      t.hazardPoint2,
                      t.hazardPoint3,
                      t.hazardPoint4,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final iconColor = isDark ? Colors.white70 : const Color(0xFF71829E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162033) : Colors.white,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,

              decoration: BoxDecoration(
                color: color.withOpacity(0.15),

                borderRadius: BorderRadius.circular(15),
              ),

              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 16,

                      fontWeight: FontWeight.w800,

                      color: isDark ? Colors.white : const Color(0xFF0B1B3A),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,

                    style: TextStyle(
                      fontSize: 13,

                      color: isDark ? Colors.white70 : const Color(0xFF71829E),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniCategory extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final List<String> points;

  const _MiniCategory({
    required this.label,
    required this.icon,
    required this.description,
    required this.points,
  });

  void _showInfo(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final softBlueBg = isDark
        ? const Color(0xFF1E2A44)
        : const Color(0xFFEAF1FF);

    final infoBoxColor = isDark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF6F8FC);

    final dragHandleColor = isDark
        ? Colors.white24
        : Colors.black.withOpacity(0.10);

    const primaryBlue = Color(0xFF2F6FE4);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dragHandleColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: softBlueBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(icon, color: primaryBlue, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: textSoft,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(
                      color: infoBoxColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.whatItMayInvolve,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...points.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Color(0xFF77D68D),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: textDark,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.reportRole);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        t.reportNow,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showInfo(context);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF162033)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF2F6FE4)),

            const SizedBox(height: 8),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF0B1B3A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

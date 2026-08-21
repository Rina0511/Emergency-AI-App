import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../../app_settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  bool _pushNotifications = true;
  bool _soundAlerts = true;
  bool _vibrationAlerts = true;
  bool _shareLiveLocation = true;
  bool _autoSendSos = true;
  bool _darkMode = false;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _language = 'en';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  bool get _isMalay {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'ms' || code == 'bm';
  }

  String _tr(String en, String ms) => _isMalay ? ms : en;

  Future<void> _loadAllData() async {
    await Future.wait([_loadUser(), _loadSettings()]);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadUser() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    setState(() {
      _name = (data?['name'] ?? user?.displayName ?? 'User').toString();
      _email = (data?['email'] ?? user?.email ?? '').toString();
      _phone = (data?['phone'] ?? '').toString();
      _language = (data?['languageCode'] ?? 'en').toString();
    });
  }

  Future<void> _loadSettings() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('app_settings')
        .doc(user!.uid)
        .get();

    final data = doc.data();
    if (data == null) return;

    setState(() {
      _pushNotifications = data['pushNotifications'] ?? true;
      _soundAlerts = data['soundAlerts'] ?? true;
      _vibrationAlerts = data['vibrationAlerts'] ?? true;
      _shareLiveLocation = data['shareLiveLocation'] ?? true;
      _autoSendSos = data['autoSendSos'] ?? true;
      _darkMode = data['darkMode'] ?? false;
      _language = data['languageCode'] ?? _language;
    });
  }

  Future<void> _saveSettings() async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('app_settings')
        .doc(user!.uid)
        .set({
          'pushNotifications': _pushNotifications,
          'soundAlerts': _soundAlerts,
          'vibrationAlerts': _vibrationAlerts,
          'shareLiveLocation': _shareLiveLocation,
          'autoSendSos': _autoSendSos,
          'darkMode': _darkMode,
          'languageCode': _language,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'uid': user!.uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'languageCode': _language,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user!.updateDisplayName(name.trim());

    if (!mounted) return;

    setState(() {
      _name = name.trim();
      _email = email.trim();
      _phone = phone.trim();
    });

    _showSnack(_tr('Profile updated', 'Profil dikemas kini'));
  }

  Future<void> _copyUserId() async {
    final uid = user?.uid ?? '';

    if (uid.isEmpty) {
      _showSnack(_tr('User ID not available', 'ID pengguna tidak tersedia'));
      return;
    }

    await Clipboard.setData(ClipboardData(text: uid));

    _showSnack(
      _tr(
        'App User ID copied. Share it with trusted emergency contacts only.',
        'App User ID disalin. Kongsi hanya dengan kenalan kecemasan yang dipercayai.',
      ),
    );
  }

  Future<void> _updateLanguage(String value) async {
    setState(() => _language = value);

    await appSettingsController.changeLanguage(value);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user!.uid,
        'languageCode': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await _saveSettings();

    _showSnack(
      value == 'ms'
          ? 'Bahasa ditukar kepada Bahasa Melayu'
          : 'Language changed to English',
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final handleColor = isDark ? Colors.white24 : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        const primaryBlue = Color(0xFF2F6FE4);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 48,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _tr('Edit Profile', 'Edit Profil'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tr(
                      'Update your emergency account information.',
                      'Kemas kini maklumat akaun kecemasan anda.',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: textSoft,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _TextInput(
                    controller: nameCtrl,
                    label: _tr('Full Name', 'Nama Penuh'),
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _TextInput(
                    controller: emailCtrl,
                    label: _tr('Email', 'E-mel'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _TextInput(
                    controller: phoneCtrl,
                    label: _tr('Phone Number', 'Nombor Telefon'),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _updateProfile(
                          name: nameCtrl.text,
                          email: emailCtrl.text,
                          phone: phoneCtrl.text,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        _tr('Save Changes', 'Simpan Perubahan'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BottomSheetCard(
          title: _tr('Language', 'Bahasa'),
          subtitle: _tr(
            'Choose your preferred app language.',
            'Pilih bahasa aplikasi yang anda mahu.',
          ),
          children: [
            _OptionTile(
              icon: Icons.language_outlined,
              title: 'English',
              subtitle: 'Use English language',
              selected: _language == 'en',
              onTap: () {
                Navigator.pop(context);
                _updateLanguage('en');
              },
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.translate_outlined,
              title: 'Bahasa Melayu',
              subtitle: 'Guna Bahasa Melayu',
              selected: _language == 'ms',
              onTap: () {
                Navigator.pop(context);
                _updateLanguage('ms');
              },
            ),
          ],
        );
      },
    );
  }

  void _showRateAppDialog() {
    int selectedRating = 5;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                _tr('Rate Emergency AI App', 'Nilai Emergency AI App'),
                style: TextStyle(color: textDark, fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tr(
                      'How useful is this app for emergency guidance?',
                      'Sejauh mana aplikasi ini membantu untuk panduan kecemasan?',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSoft),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return IconButton(
                        onPressed: () {
                          setDialogState(() => selectedRating = rating);
                        },
                        icon: Icon(
                          rating <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFB020),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_tr('Cancel', 'Batal')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('app_ratings')
                          .doc(user!.uid)
                          .set({
                            'rating': selectedRating,
                            'userId': user!.uid,
                            'createdAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                    }

                    if (!mounted) return;
                    Navigator.pop(context);
                    _showSnack(
                      _tr(
                        'Thank you for rating!',
                        'Terima kasih atas penilaian!',
                      ),
                    );
                  },
                  child: Text(_tr('Submit', 'Hantar')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialogBox() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Emergency AI App',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w900),
          ),
          content: Text(
            _tr(
              'Emergency AI App uses AI to classify emergency images, generate safety guidance, prepare SOS messages, and support emergency contact updates. For real emergencies in Malaysia, call 999 immediately.',
              'Emergency AI App menggunakan AI untuk mengklasifikasikan imej kecemasan, menjana panduan keselamatan, menyediakan mesej SOS, dan menyokong kemas kini kenalan kecemasan. Untuk kecemasan sebenar di Malaysia, hubungi 999 segera.',
            ),
            style: TextStyle(height: 1.45, color: textSoft),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_tr('Close', 'Tutup')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    const primaryBlue = Color(0xFF2F6FE4);
    const dangerRed = Color(0xFFE12529);

    final appUserId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 19,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.settings,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.18 : 0.04,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 58,
                            width: 58,
                            decoration: BoxDecoration(
                              color: softBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: primaryBlue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name.isEmpty ? 'User' : _name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email.isEmpty ? 'No email' : _email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textSoft,
                                  ),
                                ),
                                if (_phone.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    _phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: textSoft,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _showEditProfileSheet,
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SettingsSection(
                      title: _tr('App User ID', 'ID Pengguna Aplikasi'),
                      children: [
                        _UserIdTile(
                          uid: appUserId,
                          onCopy: _copyUserId,
                          title: _tr(
                            'Your App User ID / UID',
                            'App User ID / UID Anda',
                          ),
                          subtitle: _tr(
                            'Share this ID only with trusted emergency contacts so they can add you for in-app emergency updates.',
                            'Kongsi ID ini hanya dengan kenalan kecemasan dipercayai supaya mereka boleh tambah anda untuk kemas kini kecemasan dalam aplikasi.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingsSection(
                      title: _tr('Emergency Preferences', 'Tetapan Kecemasan'),
                      children: [
                        _SwitchTile(
                          icon: Icons.notifications_active_outlined,
                          title: t.pushNotifications,
                          subtitle: _tr(
                            'Receive emergency status updates.',
                            'Terima kemas kini status kecemasan.',
                          ),
                          value: _pushNotifications,
                          onChanged: (v) {
                            setState(() => _pushNotifications = v);
                            _saveSettings();
                          },
                        ),
                        _SwitchTile(
                          icon: Icons.volume_up_outlined,
                          title: t.soundAlerts,
                          subtitle: _tr(
                            'Play sound for important alerts.',
                            'Mainkan bunyi untuk amaran penting.',
                          ),
                          value: _soundAlerts,
                          onChanged: (v) {
                            setState(() => _soundAlerts = v);
                            _saveSettings();
                          },
                        ),
                        _SwitchTile(
                          icon: Icons.vibration_outlined,
                          title: t.vibrationAlerts,
                          subtitle: _tr(
                            'Vibrate during urgent alerts.',
                            'Getaran semasa amaran kecemasan.',
                          ),
                          value: _vibrationAlerts,
                          onChanged: (v) {
                            setState(() => _vibrationAlerts = v);
                            _saveSettings();
                          },
                        ),
                        _SwitchTile(
                          icon: Icons.share_location_outlined,
                          title: t.shareLiveLocation,
                          subtitle: _tr(
                            'Attach GPS location to emergency reports.',
                            'Lampirkan lokasi GPS pada laporan kecemasan.',
                          ),
                          value: _shareLiveLocation,
                          onChanged: (v) {
                            setState(() => _shareLiveLocation = v);
                            _saveSettings();
                          },
                        ),
                        _SwitchTile(
                          icon: Icons.sos_outlined,
                          title: t.autoSosMessage,
                          subtitle: _tr(
                            'Allow SOS message for victim mode.',
                            'Benarkan mesej SOS untuk mod mangsa.',
                          ),
                          value: _autoSendSos,
                          onChanged: (v) {
                            setState(() => _autoSendSos = v);
                            _saveSettings();
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingsSection(
                      title: _tr('App Preferences', 'Tetapan Aplikasi'),
                      children: [
                        _ActionTile(
                          icon: Icons.language_outlined,
                          title: _tr('Language', 'Bahasa'),
                          subtitle: _language == 'ms'
                              ? 'Bahasa Melayu'
                              : 'English',
                          onTap: _showLanguageSheet,
                        ),
                        _SwitchTile(
                          icon: Icons.dark_mode_outlined,
                          title: _tr('Dark Theme', 'Tema Gelap'),
                          subtitle: _tr(
                            'Save your preferred display mode.',
                            'Simpan mod paparan pilihan anda.',
                          ),
                          value: _darkMode,
                          onChanged: (v) async {
                            setState(() => _darkMode = v);
                            await appSettingsController.changeTheme(v);
                            await _saveSettings();

                            _showSnack(
                              v
                                  ? _tr(
                                      'Dark theme applied',
                                      'Tema gelap digunakan',
                                    )
                                  : _tr(
                                      'Light theme applied',
                                      'Tema cerah digunakan',
                                    ),
                            );
                          },
                        ),
                        _ActionTile(
                          icon: Icons.star_rate_outlined,
                          title: _tr('Rate App', 'Nilai Aplikasi'),
                          subtitle: _tr(
                            'Give feedback for this application.',
                            'Beri maklum balas untuk aplikasi ini.',
                          ),
                          onTap: _showRateAppDialog,
                        ),
                        _ActionTile(
                          icon: Icons.info_outline_rounded,
                          title: _tr('About App', 'Tentang Aplikasi'),
                          subtitle: _tr(
                            'Emergency AI App information.',
                            'Maklumat Emergency AI App.',
                          ),
                          onTap: _showAboutDialogBox,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        t.logOut,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _UserIdTile extends StatelessWidget {
  const _UserIdTile({
    required this.uid,
    required this.onCopy,
    required this.title,
    required this.subtitle,
  });

  final String uid;
  final VoidCallback onCopy;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, color: primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            uid.isEmpty ? 'Not available' : uid,
            style: TextStyle(
              fontSize: 13.2,
              fontWeight: FontWeight.w700,
              color: textDark,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSoft,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFEAF1FB);

    const primaryBlue = Color(0xFF2F6FE4);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primaryBlue, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.2,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: primaryBlue,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFEAF1FB);

    const primaryBlue = Color(0xFF2F6FE4);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: softBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: primaryBlue, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.2,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: textSoft,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryBlue),
        labelText: label,
        labelStyle: TextStyle(color: textSoft),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _BottomSheetCard extends StatelessWidget {
  const _BottomSheetCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final handleColor = isDark ? Colors.white24 : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 48,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: textSoft,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tileColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);
    const successGreen = Color(0xFF34C759);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primaryBlue : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.2,
                      color: textSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: successGreen),
          ],
        ),
      ),
    );
  }
}

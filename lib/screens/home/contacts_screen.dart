import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? get _contactsRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('emergency_contacts');
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri(scheme: 'tel', path: _cleanPhone(phone));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('Unable to open phone dialer.');
    }
  }

  Future<void> _sendSms(String phone, String name) async {
    final uri = Uri(
      scheme: 'sms',
      path: _cleanPhone(phone),
      queryParameters: {
        'body':
            'Emergency AI App test message.\n\nHi $name, you are saved as my emergency contact.',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('Unable to open SMS app.');
    }
  }

  Future<void> _sendWhatsApp(String phone, String name) async {
    final msg = Uri.encodeComponent(
      'Emergency AI App test message.\n\nHi $name, you are saved as my emergency contact.',
    );
    final uri = Uri.parse('https://wa.me/${_cleanPhone(phone)}?text=$msg');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Unable to open WhatsApp.');
    }
  }

  Future<void> _saveContact({
    String? docId,
    required String name,
    required String phone,
    required String relation,
    required bool isPrimary,
    String? contactUserId,
  }) async {
    final ref = _contactsRef;
    if (ref == null) {
      _showSnack('Please login first.');
      return;
    }

    if (name.trim().isEmpty ||
        phone.trim().isEmpty ||
        relation.trim().isEmpty) {
      _showSnack('Please fill in name, phone, and relationship.');
      return;
    }

    if (isPrimary) {
      final existing = await ref.get();
      for (final doc in existing.docs) {
        await doc.reference.set({'isPrimary': false}, SetOptions(merge: true));
      }
    }

    final data = {
      'name': name.trim(),
      'phone': phone.trim(),
      'relation': relation.trim(),
      'isPrimary': isPrimary,
      'contactUserId': contactUserId?.trim() ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (docId == null) {
      await ref.add({...data, 'createdAt': FieldValue.serverTimestamp()});
      _showSnack('Emergency contact added.');
    } else {
      await ref.doc(docId).set(data, SetOptions(merge: true));
      _showSnack('Emergency contact updated.');
    }
  }

  Future<void> _deleteContact(String docId) async {
    final ref = _contactsRef;
    if (ref == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Contact?',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This contact will be removed from your emergency list.',
          style: TextStyle(color: textSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE12529),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.doc(docId).delete();
    _showSnack('Contact deleted.');
  }

  Future<void> _setPrimary(String docId) async {
    final ref = _contactsRef;
    if (ref == null) return;

    final existing = await ref.get();
    for (final doc in existing.docs) {
      await doc.reference.set({
        'isPrimary': doc.id == docId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _showSnack('Primary contact updated.');
  }

  void _showAddOrEditContactSheet({
    String? docId,
    Map<String, dynamic>? contact,
  }) {
    final nameCtrl = TextEditingController(text: contact?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: contact?['phone'] ?? '');
    final relationCtrl = TextEditingController(
      text: contact?['relation'] ?? '',
    );
    final appUserIdCtrl = TextEditingController(
      text: contact?['contactUserId'] ?? '',
    );

    bool isPrimary = contact?['isPrimary'] == true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white24
                            : Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        docId == null
                            ? 'Add Emergency Contact'
                            : 'Edit Emergency Contact',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ContactInputField(
                      controller: nameCtrl,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    _ContactInputField(
                      controller: phoneCtrl,
                      hint: 'Phone Number',
                      icon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _ContactInputField(
                      controller: relationCtrl,
                      hint: 'Relationship',
                      icon: Icons.people_outline,
                    ),
                    const SizedBox(height: 14),
                    _ContactInputField(
                      controller: appUserIdCtrl,
                      hint: 'App User ID / UID (optional for in-app alerts)',
                      icon: Icons.verified_user_outlined,
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: isPrimary,
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: const Color(0xFF2F6FE4),
                      title: Text(
                        'Set as primary contact',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      subtitle: Text(
                        'Primary contact will be prioritized in emergencies.',
                        style: TextStyle(
                          color: textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onChanged: (v) {
                        setSheetState(() => isPrimary = v);
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _saveContact(
                            docId: docId,
                            name: nameCtrl.text,
                            phone: phoneCtrl.text,
                            relation: relationCtrl.text,
                            isPrimary: isPrimary,
                            contactUserId: appUserIdCtrl.text,
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F6FE4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          docId == null ? 'Save Contact' : 'Update Contact',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showContactOptions(String docId, Map<String, dynamic> contact) {
    final name = (contact['name'] ?? 'Contact').toString();
    final phone = (contact['phone'] ?? '').toString();
    final relation = (contact['relation'] ?? '').toString();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final avatarBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white24
                        : Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: avatarBg,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F6FE4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$relation • $phone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: textSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _OptionButton(
                  icon: Icons.call_outlined,
                  label: 'Call Contact',
                  color: const Color(0xFF2F6FE4),
                  onTap: () {
                    Navigator.pop(context);
                    _callContact(phone);
                  },
                ),
                const SizedBox(height: 10),
                _OptionButton(
                  icon: Icons.sms_outlined,
                  label: 'Send SMS Test',
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    Navigator.pop(context);
                    _sendSms(phone, name);
                  },
                ),
                const SizedBox(height: 10),
                _OptionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Send WhatsApp Test',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    _sendWhatsApp(phone, name);
                  },
                ),
                const SizedBox(height: 10),
                _OptionButton(
                  icon: Icons.star_outline_rounded,
                  label: 'Set as Primary',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    _setPrimary(docId);
                  },
                ),
                const SizedBox(height: 10),
                _OptionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit Contact',
                  color: const Color(0xFF71829E),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddOrEditContactSheet(docId: docId, contact: contact);
                  },
                ),
                const SizedBox(height: 10),
                _OptionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete Contact',
                  color: const Color(0xFFE53935),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteContact(docId);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _cleanPhone(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    if (cleaned.startsWith('0')) {
      cleaned = '60${cleaned.substring(1)}';
    }

    return cleaned;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final ref = _contactsRef;
    final size = MediaQuery.of(context).size;
    final isSmallPhone = size.width < 380;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);
    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    const primaryBlue = Color(0xFF2F6FE4);

    if (ref == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            'Please login to manage emergency contacts.',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditContactSheet(),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: Text(
          isSmallPhone ? 'Add' : 'Add Contact',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ref.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load contacts: ${snapshot.error}',
                  style: TextStyle(color: textDark),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            docs.sort((a, b) {
              final aPrimary = a.data()['isPrimary'] == true ? 1 : 0;
              final bPrimary = b.data()['isPrimary'] == true ? 1 : 0;
              return bPrimary.compareTo(aPrimary);
            });

            return Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallPhone ? 16 : 20,
                16,
                isSmallPhone ? 16 : 20,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.mainShell,
                            (route) => false,
                          );
                        },
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: textDark,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Emergency Contacts',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallPhone ? 24 : 28,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage trusted contacts for emergency calls, SMS alerts, WhatsApp alerts, and in-app emergency updates.',
                    maxLines: isSmallPhone ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallPhone ? 14 : 15,
                      height: 1.45,
                      color: textSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: isSmallPhone ? 48 : 52,
                          width: isSmallPhone ? 48 : 52,
                          decoration: BoxDecoration(
                            color: softBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SOS Contact Protection',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmallPhone ? 15 : 16,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Primary and saved contacts can receive emergency updates from your app flow.',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmallPhone ? 13.2 : 14,
                                  height: 1.4,
                                  color: textSoft,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Saved Contacts',
                          style: TextStyle(
                            fontSize: isSmallPhone ? 17 : 18,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: softBlue,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${docs.length} contacts',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: docs.isEmpty
                        ? Center(
                            child: Text(
                              'No emergency contacts yet.\nTap Add Contact to create one.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSoft,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 150),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              return _ContactCard(
                                contact: doc.data(),
                                onTap: () =>
                                    _showContactOptions(doc.id, doc.data()),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.onTap});

  final Map<String, dynamic> contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallPhone = size.width < 380;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    const primaryBlue = Color(0xFF2F6FE4);

    final name = (contact['name'] ?? 'Contact').toString();
    final phone = (contact['phone'] ?? '').toString();
    final relation = (contact['relation'] ?? '').toString();
    final isPrimary = contact['isPrimary'] == true;
    final hasAppId = (contact['contactUserId'] ?? '')
        .toString()
        .trim()
        .isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 14 : 18,
          vertical: isSmallPhone ? 15 : 18,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              height: isSmallPhone ? 48 : 52,
              width: isSmallPhone ? 48 : 52,
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallPhone ? 16 : 17,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (isPrimary) const _Tag(text: 'Primary'),
                      if (hasAppId) const _Tag(text: 'In-App'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    relation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: textSoft, size: 26),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tagBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2F6FE4),
        ),
      ),
    );
  }
}

class _ContactInputField extends StatelessWidget {
  const _ContactInputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final inputBg = isDark ? const Color(0xFF162033) : Colors.white;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 15.5,
        color: textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSoft, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: textSoft),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: color.withValues(alpha: isDark ? 0.14 : 0.06),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

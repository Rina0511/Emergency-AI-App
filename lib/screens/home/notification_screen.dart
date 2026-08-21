import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance.collection('notifications').doc(docId).set(
      {'isRead': true},
      SetOptions(merge: true),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    _markAsRead(docId);

    final title = (data['title'] ?? 'Emergency Alert').toString();
    final message = (data['message'] ?? '').toString();
    final location = (data['location'] ?? '').toString();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final handleColor = isDark ? Colors.white24 : const Color(0xFFE2E8F0);

    const primaryBlue = Color(0xFF2F6FE4);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 55,
                      height: 5,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: textSoft,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SelectableText(''),
                    SelectableText(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
    final user = FirebaseAuth.instance.currentUser;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);
    const red = Color(0xFFE12529);

    if (user == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            'Please login to view notifications',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textDark,
        title: Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900, color: textDark),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load notifications.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
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
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['createdAt'];
            final bTime = bData['createdAt'];

            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }
            return 0;
          });

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = (data['title'] ?? 'Emergency Alert').toString();
              final shortMessage =
                  (data['shortMessage'] ?? 'Emergency update received.')
                      .toString();
              final isRead = data['isRead'] == true;
              final type = (data['type'] ?? 'general').toString();

              final iconColor = _iconColor(type);

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _showNotificationDetails(context, doc.id, data),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isRead
                          ? Colors.transparent
                          : red.withValues(alpha: isDark ? 0.50 : 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(_icon(type), color: iconColor, size: 25),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              shortMessage,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: textSoft,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isRead ? 'Read' : 'New Emergency Alert',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: isRead ? textSoft : red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _icon(String type) {
    switch (type) {
      case 'sos':
      case 'emergency_update':
      case 'tracking_update':
        return Icons.warning_amber_rounded;
      case 'tracking':
        return Icons.location_on_outlined;
      case 'alert':
        return Icons.notifications_active_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  static Color _iconColor(String type) {
    switch (type) {
      case 'sos':
      case 'alert':
      case 'emergency_update':
      case 'tracking_update':
        return const Color(0xFFE12529);
      case 'tracking':
        return const Color(0xFF2F6FE4);
      default:
        return const Color(0xFF34C759);
    }
  }
}

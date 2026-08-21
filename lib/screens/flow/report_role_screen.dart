import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../common/app_bottom_nav.dart';

class ReportRoleScreen extends StatefulWidget {
  const ReportRoleScreen({super.key});

  @override
  State<ReportRoleScreen> createState() => _ReportRoleScreenState();
}

class _ReportRoleScreenState extends State<ReportRoleScreen> {
  String? _selectedRole;

  void _selectRole(String value) {
    setState(() {
      _selectedRole = value;
    });
  }

  void _continue() {
    if (_selectedRole == null) return;
    Navigator.pushNamed(context, AppRoutes.upload, arguments: _selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);
    final bgBottom = isDark ? const Color(0xFF111A2E) : const Color(0xFFDEE9F8);
    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final disabledText = isDark ? Colors.white38 : const Color(0xFF7C8DA8);

    const primaryBlue = Color(0xFF2F6FE4);

    final size = MediaQuery.of(context).size;
    final isSmallPhone = size.height < 720 || size.width < 360;

    final horizontalPadding = isSmallPhone ? 16.0 : 24.0;
    final topGap = isSmallPhone ? 20.0 : 34.0;
    final titleSize = isSmallPhone ? 23.0 : 28.0;
    final cardGap = isSmallPhone ? 12.0 : 18.0;

    return Scaffold(
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 34,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: isSmallPhone ? 42 : 46,
                              width: isSmallPhone ? 42 : 46,
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
                                l10n.reportRoleHeader,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmallPhone ? 16 : 18,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: topGap),
                        Text(
                          l10n.whoNeedsHelp,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallPhone ? 4 : 10,
                          ),
                          child: Text(
                            l10n.selectYourRole,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.35,
                              color: textSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallPhone ? 22 : 32),
                        _RoleCard(
                          emoji: '🧍',
                          title: 'Someone Needs Help',
                          subtitle:
                              'I am reporting an emergency for another person.',
                          selected: _selectedRole == 'witness',
                          isSmallPhone: isSmallPhone,
                          onTap: () => _selectRole('witness'),
                        ),
                        SizedBox(height: cardGap),
                        _RoleCard(
                          emoji: '🚨',
                          title: 'Others',
                          subtitle:
                              'I am reporting another emergency or situation that requires assistance.',
                          selected: _selectedRole == 'others',
                          isSmallPhone: isSmallPhone,
                          onTap: () => _selectRole('others'),
                        ),
                        const Spacer(),
                        SizedBox(height: isSmallPhone ? 18 : 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedRole == null ? null : _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cardColor,
                              foregroundColor: _selectedRole == null
                                  ? disabledText
                                  : primaryBlue,
                              disabledBackgroundColor: cardColor.withOpacity(
                                0.95,
                              ),
                              disabledForegroundColor: disabledText,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallPhone ? 15 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.continueText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isSmallPhone ? 15 : 16,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == null
                                          ? disabledText
                                          : primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 21,
                                  color: _selectedRole == null
                                      ? disabledText
                                      : primaryBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
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

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final bool isSmallPhone;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.isSmallPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final borderColor = isDark ? Colors.white12 : Colors.white;
    final radioBorder = isDark ? Colors.white38 : const Color(0xFFD0D7E2);

    const primaryBlue = Color(0xFF2F6FE4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 14 : 18,
            vertical: isSmallPhone ? 16 : 22,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? primaryBlue.withOpacity(0.35) : borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: isSmallPhone ? 28 : 34)),
              SizedBox(width: isSmallPhone ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallPhone ? 15.5 : 17,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallPhone ? 13.2 : 14.5,
                        height: 1.3,
                        color: textSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallPhone ? 8 : 12),
              Container(
                height: isSmallPhone ? 25 : 28,
                width: isSmallPhone ? 25 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? primaryBlue : radioBorder,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Center(
                        child: Icon(Icons.circle, size: 11, color: primaryBlue),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../routes.dart';

class VictimDetailsScreen extends StatefulWidget {
  const VictimDetailsScreen({super.key});

  @override
  State<VictimDetailsScreen> createState() => _VictimDetailsScreenState();
}

class _VictimDetailsScreenState extends State<VictimDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _victimNameCtrl = TextEditingController();
  final _injuredCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();

  String _condition = 'Unknown';
  String _dangerPresent = 'Unknown';

  @override
  void dispose() {
    _victimNameCtrl.dispose();
    _injuredCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      AppRoutes.sosPreview,
      arguments: {
        'victimName': _victimNameCtrl.text.trim(),
        'injuredCount': _injuredCtrl.text.trim(),
        'condition': _condition,
        'dangerPresent': _dangerPresent,
        'notes': _notesCtrl.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFEAF1FB);
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const fieldBg = Color(0xFFF5F8FD);
    const dangerRed = Color(0xFFE53935);
    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Victim Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _InputCard(
                  label: 'Victim Name (Optional)',
                  child: TextFormField(
                    controller: _victimNameCtrl,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. John',
                      prefixIcon: Icon(Icons.person_outline),
                      filled: true,
                      fillColor: fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _InputCard(
                  label: 'Number of Injured',
                  child: TextFormField(
                    controller: _injuredCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    validator: (value) {
                      final v = (value ?? '').trim();
                      if (v.isEmpty) return 'Please enter number of injured';
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _InputCard(
                  label: 'Condition',
                  child: _StyledDropdown(
                    value: _condition,
                    items: const [
                      'Unknown',
                      'Conscious',
                      'Unconscious',
                      'Bleeding',
                      'Trapped',
                      'Breathing difficulty',
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _condition = value);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                _InputCard(
                  label: 'Danger Present',
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: dangerRed,
                    size: 20,
                  ),
                  child: _StyledDropdown(
                    value: _dangerPresent,
                    items: const [
                      'Unknown',
                      'No',
                      'Fire',
                      'Smoke',
                      'Traffic hazard',
                      'Chemical risk',
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _dangerPresent = value);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                _InputCard(
                  label: 'Additional Notes',
                  child: TextFormField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Driver trapped inside car.',
                      filled: true,
                      fillColor: fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? leading;

  const _InputCard({required this.label, required this.child, this.leading});

  @override
  Widget build(BuildContext context) {
    const textSoft = Color(0xFF71829E);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading == null)
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: textSoft,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Row(
              children: [
                leading!,
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const fieldBg = Color(0xFFF5F8FD);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textSoft),
          style: const TextStyle(
            fontSize: 15.5,
            color: textDark,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(18),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../common/app_bottom_nav.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};

    final reportId = args['reportId']?.toString();
    final emergencyId = args['emergencyId']?.toString() ?? reportId;

    final role = (args['role'] ?? 'someoneElse').toString();

    final isSomeoneElse = role.toLowerCase() == 'someoneelse';
    final incidentCategory = (args['incidentCategory'] ?? 'Human').toString();

    final incidentSubType = (args['incidentSubType'] ?? 'Unknown').toString();
    final emergencyType = (args['emergencyType'] ?? l10n.accident).toString();

    final confidence = _parseConfidence(args['confidence']);
    final location = (args['location'] ?? 'Location not shared').toString();

    final isVictim = role.toLowerCase() == 'victim';
    final localeCode = Localizations.localeOf(context).languageCode;

    final severity =
        (args['severity'] ??
                _severityText(
                  confidence: confidence,
                  localeCode: localeCode,
                ).replaceAll('Severity: ', '').replaceAll('Tahap: ', ''))
            .toString();

    final steps = _getSafetySteps(
      incidentCategory: incidentCategory,
      incidentSubType: incidentSubType,
      emergencyType: emergencyType,
      role: role,
      l10n: l10n,
      localeCode: localeCode,
    );

    final equipment = _getEquipment(
      incidentCategory: incidentCategory,
      incidentSubType: incidentSubType,
      emergencyType: emergencyType,
      role: role,
      l10n: l10n,
      localeCode: localeCode,
    );

    final responders = _getResponders(
      emergencyType: emergencyType,
      l10n: l10n,
      localeCode: localeCode,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    final warningBg = isDark
        ? const Color(0xFF2A1720)
        : const Color(0xFFFFEEF0);

    final warningBorder = isDark
        ? const Color(0xFF7F1D1D)
        : const Color(0xFFF3B4BC);

    const primaryBlue = Color(0xFF2F6FE4);
    const red = Color(0xFFE53935);

    Map<String, dynamic> nextArgs() {
      return {
        ...args,
        'reportId': reportId,
        'emergencyId': emergencyId,
        'role': role,
        'incidentCategory': incidentCategory,
        'incidentSubType': incidentSubType,
        'emergencyType': emergencyType,
        'confidence': confidence,
        'severity': severity,
        'location': location,
        'victimCount': args['victimCount'] ?? args['injuredCount'] ?? 1,
        'injuredCount': args['injuredCount'] ?? args['victimCount'] ?? 1,
        'condition': args['condition'] ?? 'Unknown',
        'dangerPresent': args['dangerPresent'] ?? 'Unknown',
        'notes': args['notes'] ?? '',
        'summary': args['summary'] ?? '',
        'evidence': args['evidence'] ?? [],
        'responders': responders.map((e) => e.title).toList(),
        'equipment': equipment.map((e) => e.label).toList(),
        'safetySteps': steps,
        'status': 'active',
        'trackingStage': args['trackingStage'] ?? 'sent',
      };
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.safetyGuidance,
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                role == "someoneElse"
                    ? "Guidance for assisting another person."
                    : "Guidance for animal, property or environmental emergencies.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: warningBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: warningBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: red,
                      size: 34,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$emergencyType • ${(confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_tr(localeCode, 'Severity', 'Tahap')}: $severity',
                            style: TextStyle(
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
              const SizedBox(height: 20),
              _CardSection(
                title: l10n.immediateSafetySteps,
                trailing: _Pill(
                  text: role == "someoneElse"
                      ? "Helping Others"
                      : "General Guidance",
                ),
                child: Column(
                  children: steps.map((step) => _StepItem(text: step)).toList(),
                ),
              ),
              const SizedBox(height: 18),
              _CardSection(
                title: l10n.suggestedEquipment,
                trailing: _Pill(text: _tr(localeCode, 'Checklist', 'Senarai')),
                child: Column(
                  children: [
                    GridView.builder(
                      itemCount: equipment.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.28,
                          ),
                      itemBuilder: (context, index) {
                        final item = equipment[index];
                        return _EquipmentCard(
                          icon: item.icon,
                          label: item.label,
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isVictim
                          ? _tr(
                              localeCode,
                              'These items are recommended for responders coming to assist you.',
                              'Item ini dicadangkan untuk responder yang datang membantu anda.',
                            )
                          : _tr(
                              localeCode,
                              'These items are recommended if you or responders are assisting the victim.',
                              'Item ini dicadangkan jika anda atau responder membantu mangsa.',
                            ),
                      style: TextStyle(
                        fontSize: 14.2,
                        color: textSoft,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _CardSection(
                title: l10n.recommendedResponders,
                trailing: _Pill(
                  text: _tr(localeCode, 'AI Suggested', 'Cadangan AI'),
                ),
                child: Column(
                  children: responders
                      .map(
                        (responder) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ResponderTile(
                            icon: responder.icon,
                            title: responder.title,
                            subtitle: responder.subtitle,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: softBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tr(
                              localeCode,
                              'Detected Location',
                              'Lokasi Dikesan',
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSoft,
                              height: 1.35,
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.liveTracking,
                      arguments: nextArgs(),
                    );
                  },
                  icon: const Icon(Icons.location_searching_rounded),
                  label: Text(
                    _tr(
                      localeCode,
                      'Track Emergency Response',
                      'Jejak Tindak Balas Kecemasan',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  static double _parseConfidence(dynamic value) {
    if (value is double) return value > 1 ? value / 100 : value;
    if (value is int) return value > 1 ? value / 100 : value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed > 1 ? parsed / 100 : parsed;
    }
    return 0.92;
  }

  static String _severityText({
    required double confidence,
    required String localeCode,
  }) {
    String level;

    if (confidence >= 0.85) {
      level = _tr(localeCode, 'High', 'Tinggi');
    } else if (confidence >= 0.60) {
      level = _tr(localeCode, 'Medium', 'Sederhana');
    } else {
      level = _tr(localeCode, 'Low', 'Rendah');
    }

    return '${_tr(localeCode, 'Severity', 'Tahap')}: $level';
  }

  static String _tr(String localeCode, String en, String ms) {
    return localeCode == 'ms' || localeCode == 'bm' ? ms : en;
  }

  static List<String> _getSafetySteps({
    required String incidentCategory,
    required String incidentSubType,
    required String emergencyType,
    required String role,
    required AppLocalizations l10n,
    required String localeCode,
  }) {
    final category = incidentCategory.toLowerCase();
    final subType = incidentSubType.toLowerCase();
    final type = emergencyType.toLowerCase();

    if (role == "others") {
      if (type.contains('fire') || type.contains('kebakaran')) {
        return [
          _tr(
            localeCode,
            'Move to a safe distance and avoid smoke.',
            'Bergerak ke tempat selamat dan elakkan asap.',
          ),
          _tr(
            localeCode,
            'Call emergency services and share the exact location.',
            'Hubungi kecemasan dan berikan lokasi tepat.',
          ),
          _tr(
            localeCode,
            'Warn nearby people if it is safe to do so.',
            'Beri amaran kepada orang berdekatan jika selamat.',
          ),
          _tr(
            localeCode,
            'Do not enter the burning area.',
            'Jangan masuk ke kawasan terbakar.',
          ),
          l10n.callEmergency,
        ];
      }

      if (type.contains('medical') || type.contains('perubatan')) {
        return [
          _tr(
            localeCode,
            'Ensure the area is safe before helping.',
            'Pastikan kawasan selamat sebelum membantu.',
          ),
          _tr(
            localeCode,
            'Call emergency services immediately.',
            'Hubungi kecemasan dengan segera.',
          ),
          _tr(
            localeCode,
            'Check the victim condition and keep them calm.',
            'Periksa keadaan mangsa dan tenangkan mereka.',
          ),
          _tr(
            localeCode,
            'Do not move the injured person unless necessary.',
            'Jangan alihkan mangsa kecuali perlu.',
          ),
          _tr(
            localeCode,
            'Share location and important details with responders.',
            'Kongsi lokasi dan maklumat penting kepada responder.',
          ),
        ];
      }

      return [
        _tr(
          localeCode,
          'Stay safe and keep distance from danger.',
          'Utamakan keselamatan dan jauhkan diri dari bahaya.',
        ),
        _tr(
          localeCode,
          'Call emergency services.',
          'Hubungi perkhidmatan kecemasan.',
        ),
        _tr(
          localeCode,
          'Provide location and describe what happened.',
          'Berikan lokasi dan terangkan kejadian.',
        ),
        _tr(
          localeCode,
          'Observe important details for responders.',
          'Perhatikan butiran penting untuk responder.',
        ),
        _tr(
          localeCode,
          'Help the victim only when it is safe.',
          'Bantu mangsa hanya jika selamat.',
        ),
      ];
    }

    if (type.contains('fire') || type.contains('kebakaran')) {
      return [
        l10n.stayCalm,
        l10n.fireStayLow,
        _tr(
          localeCode,
          'Leave the area immediately if unsafe',
          'Tinggalkan kawasan segera jika tidak selamat',
        ),
        _tr(localeCode, 'Do not use lifts', 'Jangan gunakan lif'),
        l10n.callEmergency,
      ];
    }

    if (type.contains('medical') || type.contains('perubatan')) {
      return [
        l10n.stayCalm,
        _tr(
          localeCode,
          'Check if the person is breathing',
          'Periksa sama ada mangsa bernafas',
        ),
        _tr(
          localeCode,
          'Keep the person comfortable and still',
          'Pastikan mangsa selesa dan tidak banyak bergerak',
        ),
        _tr(
          localeCode,
          'Do not give food or drink',
          'Jangan beri makanan atau minuman',
        ),
        l10n.callEmergency,
      ];
    }

    if (type.contains('crime') || type.contains('jenayah')) {
      return [
        l10n.stayCalm,
        _tr(
          localeCode,
          'Move away from danger immediately',
          'Bergerak jauh dari bahaya dengan segera',
        ),
        _tr(
          localeCode,
          'Do not confront the suspect',
          'Jangan berdepan dengan suspek',
        ),
        _tr(
          localeCode,
          'Observe and remember important details',
          'Perhatikan dan ingat butiran penting',
        ),
        l10n.callEmergency,
      ];
    }

    if (type.contains('hazard') || type.contains('bahaya')) {
      return [
        l10n.stayCalm,
        l10n.moveSafe,
        _tr(
          localeCode,
          'Avoid touching suspicious materials',
          'Elakkan menyentuh bahan yang mencurigakan',
        ),
        _tr(
          localeCode,
          'Warn nearby people',
          'Beri amaran kepada orang berdekatan',
        ),
        l10n.callEmergency,
      ];
    }
    if (type.contains('animal rescue')) {
      return [
        _tr(
          localeCode,
          'Stay calm and do not attempt a dangerous rescue.',
          'Bertenang dan jangan cuba menyelamatkan haiwan secara berbahaya.',
        ),
        _tr(
          localeCode,
          'Keep people away from the rescue area.',
          'Pastikan orang ramai menjauhi kawasan tersebut.',
        ),
        _tr(
          localeCode,
          'Observe the animal from a safe distance.',
          'Perhatikan haiwan dari jarak yang selamat.',
        ),
        _tr(
          localeCode,
          'Contact the Fire and Rescue Department if professional rescue is required.',
          'Hubungi Bomba jika bantuan penyelamatan diperlukan.',
        ),
        l10n.callEmergency,
      ];
    }
    if (type.contains('animal observation')) {
      return [
        _tr(
          localeCode,
          'No immediate emergency has been detected.',
          'Tiada kecemasan segera dikesan.',
        ),
        _tr(
          localeCode,
          'Observe the animal from a safe distance.',
          'Perhatikan haiwan dari jarak yang selamat.',
        ),
        _tr(
          localeCode,
          'Do not disturb or frighten the animal.',
          'Jangan mengganggu atau menakutkan haiwan.',
        ),
        _tr(
          localeCode,
          'Contact local animal welfare only if the animal becomes trapped or injured.',
          'Hubungi pihak kebajikan haiwan jika haiwan menjadi terperangkap atau cedera.',
        ),
      ];
    }
    if (type.contains('flood')) {
      return [
        _tr(
          localeCode,
          'Move immediately to higher ground.',
          'Bergerak segera ke kawasan yang lebih tinggi.',
        ),
        _tr(
          localeCode,
          'Avoid walking or driving through flood water.',
          'Jangan berjalan atau memandu melalui air banjir.',
        ),
        _tr(
          localeCode,
          'Turn off electricity if it is safe.',
          'Matikan bekalan elektrik jika selamat.',
        ),
        l10n.callEmergency,
      ];
    }
    if (type.contains('gas leak')) {
      return [
        _tr(
          localeCode,
          'Leave the building immediately.',
          'Keluar dari bangunan dengan segera.',
        ),
        _tr(
          localeCode,
          'Do not switch electrical devices on or off.',
          'Jangan hidupkan atau matikan peralatan elektrik.',
        ),
        _tr(
          localeCode,
          'Avoid flames or smoking.',
          'Elakkan api terbuka dan merokok.',
        ),
        l10n.callEmergency,
      ];
    }
    if (type.contains('building collapse')) {
      return [
        _tr(
          localeCode,
          'Move away from unstable structures.',
          'Jauhkan diri daripada struktur yang tidak stabil.',
        ),
        _tr(
          localeCode,
          'Do not enter damaged buildings.',
          'Jangan masuk ke bangunan yang rosak.',
        ),
        _tr(
          localeCode,
          'Watch for falling debris.',
          'Berhati-hati dengan runtuhan.',
        ),
        l10n.callEmergency,
      ];
    }
    if (type.contains('electrical hazard')) {
      return [
        _tr(
          localeCode,
          'Stay away from exposed electrical wires.',
          'Jauhkan diri daripada wayar elektrik yang terdedah.',
        ),
        _tr(
          localeCode,
          'Do not touch electrical equipment.',
          'Jangan sentuh peralatan elektrik.',
        ),
        _tr(
          localeCode,
          'Keep others away from the danger area.',
          'Pastikan orang lain menjauhi kawasan bahaya.',
        ),
        l10n.callEmergency,
      ];
    }
    if (type.contains('landslide')) {
      return [
        _tr(
          localeCode,
          'Move immediately away from the landslide area.',
          'Segera menjauhi kawasan tanah runtuh.',
        ),
        _tr(
          localeCode,
          'Watch for additional falling rocks or soil.',
          'Berhati-hati dengan runtuhan susulan.',
        ),
        _tr(
          localeCode,
          'Avoid returning until authorities declare it safe.',
          'Jangan kembali sehingga pihak berkuasa mengesahkan kawasan selamat.',
        ),
        l10n.callEmergency,
      ];
    }

    return [
      l10n.stayCalm,
      l10n.moveSafe,
      l10n.dontMoveInjured,
      l10n.hazardLights,
      l10n.callEmergency,
    ];
  }

  static List<_EquipmentItem> _getEquipment({
    required String incidentCategory,
    required String incidentSubType,
    required String emergencyType,
    required String role,
    required AppLocalizations l10n,
    required String localeCode,
  }) {
    if (role == "others") {
      return [
        _EquipmentItem(Icons.medical_services_outlined, l10n.firstAidKit),
        _EquipmentItem(Icons.phone_outlined, 'Mobile Phone'),
        _EquipmentItem(Icons.flashlight_on_outlined, l10n.flashlight),
        _EquipmentItem(Icons.location_on_outlined, 'Location Sharing'),
      ];
    }
    final category = incidentCategory.toLowerCase();
    final type = incidentSubType.toLowerCase();

    if (type.contains('fire')) {
      return [
        _EquipmentItem(
          Icons.fire_extinguisher,
          _tr(localeCode, 'Fire Extinguisher', 'Alat Pemadam Api'),
        ),

        _EquipmentItem(
          Icons.back_hand,
          _tr(localeCode, 'Protective Gloves', 'Sarung Tangan'),
        ),

        _EquipmentItem(
          Icons.masks,
          _tr(localeCode, 'Face Mask', 'Pelitup Muka'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),
      ];
    }

    if (type.contains('medical')) {
      return [
        _EquipmentItem(
          Icons.medical_services,
          _tr(localeCode, 'First Aid Kit', 'Kit Pertolongan Cemas'),
        ),

        _EquipmentItem(
          Icons.back_hand,
          _tr(localeCode, 'Medical Gloves', 'Sarung Tangan Perubatan'),
        ),

        _EquipmentItem(
          Icons.health_and_safety,
          _tr(localeCode, 'CPR Face Shield', 'Pelindung CPR'),
        ),

        _EquipmentItem(
          Icons.healing,
          _tr(localeCode, 'Clean Bandage', 'Pembalut Bersih'),
        ),
      ];
    }

    if (type.contains('accident')) {
      return [
        _EquipmentItem(
          Icons.warning_amber,
          _tr(localeCode, 'Warning Triangle', 'Segi Tiga Amaran'),
        ),

        _EquipmentItem(
          Icons.medical_services,
          _tr(localeCode, 'First Aid Kit', 'Kit Pertolongan Cemas'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.safety_check,
          _tr(localeCode, 'Reflective Vest', 'Vest Reflektif'),
        ),
      ];
    }

    if (type.contains('crime')) {
      return [
        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.phone_android,
          _tr(localeCode, 'Mobile Phone', 'Telefon Bimbit'),
        ),

        _EquipmentItem(Icons.campaign, _tr(localeCode, 'Whistle', 'Wisel')),

        _EquipmentItem(Icons.camera_alt, _tr(localeCode, 'Camera', 'Kamera')),
      ];
    }

    if (type.contains('hazard')) {
      return [
        _EquipmentItem(
          Icons.back_hand,
          _tr(localeCode, 'Safety Gloves', 'Sarung Tangan Keselamatan'),
        ),

        _EquipmentItem(
          Icons.masks,
          _tr(localeCode, 'Face Mask', 'Pelitup Muka'),
        ),

        _EquipmentItem(
          Icons.hiking,
          _tr(localeCode, 'Safety Boots', 'But Keselamatan'),
        ),

        _EquipmentItem(
          Icons.warning_amber,
          _tr(localeCode, 'Safety Cone', 'Kon Keselamatan'),
        ),
      ];
    }

    if (type.contains('animal rescue')) {
      return [
        _EquipmentItem(
          Icons.back_hand,
          _tr(localeCode, 'Protective Gloves', 'Sarung Tangan'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.linear_scale,
          _tr(localeCode, 'Rescue Rope', 'Tali Penyelamat'),
        ),

        _EquipmentItem(
          Icons.pets,
          _tr(
            localeCode,
            'Animal Carrier (if available)',
            'Sangkar Haiwan (jika ada)',
          ),
        ),
      ];
    }
    if (type.contains('animal observation')) {
      return [
        _EquipmentItem(
          Icons.phone_android,
          _tr(localeCode, 'Mobile Phone', 'Telefon Bimbit'),
        ),

        _EquipmentItem(Icons.camera_alt, _tr(localeCode, 'Camera', 'Kamera')),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.visibility,
          _tr(localeCode, 'Binoculars (if available)', 'Teropong (jika ada)'),
        ),
      ];
    }

    if (type.contains('flood')) {
      return [
        _EquipmentItem(
          Icons.pool,
          _tr(localeCode, 'Life Jacket', 'Jaket Keselamatan'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.local_drink,
          _tr(localeCode, 'Drinking Water', 'Air Minuman'),
        ),

        _EquipmentItem(
          Icons.inventory_2,
          _tr(localeCode, 'Emergency Kit', 'Kit Kecemasan'),
        ),
      ];
    }

    if (type.contains('gas leak')) {
      return [
        _EquipmentItem(
          Icons.masks,
          _tr(localeCode, 'Face Mask', 'Pelitup Muka'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.phone_android,
          _tr(localeCode, 'Emergency Contact List', 'Senarai Nombor Kecemasan'),
        ),

        _EquipmentItem(
          Icons.warning_amber,
          _tr(
            localeCode,
            'Gas Detector (if available)',
            'Pengesan Gas (jika ada)',
          ),
        ),
      ];
    }

    if (type.contains('building collapse')) {
      return [
        _EquipmentItem(
          Icons.health_and_safety,
          _tr(localeCode, 'Safety Helmet', 'Topi Keselamatan'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.masks,
          _tr(localeCode, 'Dust Mask', 'Topeng Habuk'),
        ),

        _EquipmentItem(
          Icons.medical_services,
          _tr(localeCode, 'First Aid Kit', 'Kit Pertolongan Cemas'),
        ),

        _EquipmentItem(
          Icons.warning_amber,
          _tr(localeCode, 'Emergency Whistle', 'Wisel Kecemasan'),
        ),
      ];
    }

    if (type.contains('electrical hazard')) {
      return [
        _EquipmentItem(
          Icons.electrical_services,
          _tr(localeCode, 'Insulated Gloves', 'Sarung Tangan Berpenebat'),
        ),

        _EquipmentItem(
          Icons.hiking,
          _tr(localeCode, 'Safety Boots', 'But Keselamatan'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.warning_amber,
          _tr(localeCode, 'Electrical Safety Sign', 'Tanda Amaran Elektrik'),
        ),

        _EquipmentItem(
          Icons.power_off,
          _tr(localeCode, 'Circuit Breaker Access', 'Akses Pemutus Litar'),
        ),
      ];
    }
    if (type.contains('landslide')) {
      return [
        _EquipmentItem(
          Icons.health_and_safety,
          _tr(localeCode, 'Safety Helmet', 'Topi Keselamatan'),
        ),

        _EquipmentItem(
          Icons.inventory_2,
          _tr(localeCode, 'Emergency Kit', 'Kit Kecemasan'),
        ),

        _EquipmentItem(
          Icons.flashlight_on,
          _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
        ),

        _EquipmentItem(
          Icons.campaign,
          _tr(localeCode, 'Emergency Whistle', 'Wisel Kecemasan'),
        ),

        _EquipmentItem(
          Icons.hiking,
          _tr(localeCode, 'Safety Boots', 'But Keselamatan'),
        ),
      ];
    }

    return [
      _EquipmentItem(
        Icons.phone_android,
        _tr(localeCode, 'Mobile Phone', 'Telefon Bimbit'),
      ),

      _EquipmentItem(
        Icons.flashlight_on,
        _tr(localeCode, 'Flashlight', 'Lampu Suluh'),
      ),

      _EquipmentItem(
        Icons.medical_services,
        _tr(localeCode, 'First Aid Kit', 'Kit Pertolongan Cemas'),
      ),

      _EquipmentItem(
        Icons.location_on,
        _tr(localeCode, 'Location Sharing', 'Perkongsian Lokasi'),
      ),
    ];
  }

  static List<_ResponderItem> _getResponders({
    required String emergencyType,
    required AppLocalizations l10n,
    required String localeCode,
  }) {
    final type = emergencyType.toLowerCase();

    if (type.contains('fire') || type.contains('kebakaran')) {
      return [
        _ResponderItem(
          icon: Icons.local_fire_department_outlined,
          title: _tr(localeCode, 'Fire Department', 'Bomba'),
          subtitle: _tr(
            localeCode,
            'Fire or smoke risk detected',
            'Risiko kebakaran atau asap dikesan',
          ),
        ),
        _ResponderItem(
          icon: Icons.local_hospital_outlined,
          title: _tr(localeCode, 'Ambulance', 'Ambulans'),
          subtitle: _tr(
            localeCode,
            'Possible injuries at scene',
            'Kemungkinan ada kecederaan di lokasi',
          ),
        ),
      ];
    }

    if (type.contains('crime') || type.contains('jenayah')) {
      return [
        _ResponderItem(
          icon: Icons.local_police_outlined,
          title: _tr(localeCode, 'Police', 'Polis'),
          subtitle: _tr(
            localeCode,
            'Threat or suspicious activity detected',
            'Ancaman atau aktiviti mencurigakan dikesan',
          ),
        ),
        _ResponderItem(
          icon: Icons.local_hospital_outlined,
          title: _tr(localeCode, 'Ambulance', 'Ambulans'),
          subtitle: _tr(
            localeCode,
            'Medical support may be needed',
            'Sokongan perubatan mungkin diperlukan',
          ),
        ),
      ];
    }

    if (type.contains('medical') || type.contains('perubatan')) {
      return [
        _ResponderItem(
          icon: Icons.local_hospital_outlined,
          title: _tr(localeCode, 'Ambulance', 'Ambulans'),
          subtitle: _tr(
            localeCode,
            'Medical emergency detected',
            'Kecemasan perubatan dikesan',
          ),
        ),
      ];
    }

    return [
      _ResponderItem(
        icon: Icons.local_hospital_outlined,
        title: _tr(localeCode, 'Ambulance', 'Ambulans'),
        subtitle: _tr(
          localeCode,
          'Injured person may need treatment',
          'Mangsa mungkin perlukan rawatan',
        ),
      ),
      _ResponderItem(
        icon: Icons.local_police_outlined,
        title: _tr(localeCode, 'Police', 'Polis'),
        subtitle: _tr(
          localeCode,
          'Traffic or area control may be needed',
          'Kawalan trafik atau kawasan mungkin diperlukan',
        ),
      ),
    ];
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF2F6FE4),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF77D68D), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.5,
                color: textDark,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    const primaryBlue = Color(0xFF2F6FE4);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.6,
                color: textDark,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponderTile extends StatelessWidget {
  const _ResponderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: innerCardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSoft,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: primaryBlue),
        ],
      ),
    );
  }
}

class _EquipmentItem {
  final IconData icon;
  final String label;

  _EquipmentItem(this.icon, this.label);
}

class _ResponderItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _ResponderItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

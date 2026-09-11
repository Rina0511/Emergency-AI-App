import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes.dart';
//import '../common/app_bottom_nav.dart';
import '../../l10n/app_localizations.dart';
import 'package:torch_light/torch_light.dart';

class AssistScreen extends StatefulWidget {
  const AssistScreen({super.key});

  @override
  State<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends State<AssistScreen> {
  //----------------------------------------------------------
  // COLORS
  //----------------------------------------------------------

  static const Color primaryBlue = Color(0xFF2F6FE4);
  static const Color dangerRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF34C759);

  //----------------------------------------------------------
  // TIMER
  //----------------------------------------------------------

  Timer? _incidentTimer;
  Duration _incidentDuration = Duration.zero;
  bool _running = false;

  //----------------------------------------------------------
  // CPR METRONOME
  //----------------------------------------------------------

  bool _cprRunning = false;

  final int _cprBeat = 110;
  int _cprBeatCount = 0;

  Timer? _beatTimer;

  bool _pulse = false;

  //----------------------------------------------------------
  // FLASHLIGHT
  //----------------------------------------------------------

  bool _flashlightOn = false;

  //----------------------------------------------------------
  // EXPANSION PANELS
  //----------------------------------------------------------

  bool _cprExpanded = true;

  bool _bleedingExpanded = false;

  bool _chokingExpanded = false;

  bool _burnExpanded = false;

  bool _fractureExpanded = false;

  bool _shockExpanded = false;

  bool _poisonExpanded = false;

  bool _electricExpanded = false;

  bool _heatExpanded = false;

  bool _drowningExpanded = false;

  bool _animalExpanded = false;
  Future<void> _turnOffFlashlightSilently() async {
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }

  //----------------------------------------------------------
  // TIMER FUNCTIONS
  //----------------------------------------------------------
  void _startTimer() {
    if (_running) return;

    setState(() {
      _running = true;
    });

    _incidentTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _incidentDuration += const Duration(seconds: 1);
      });
    });
  }

  void _pauseTimer() {
    _incidentTimer?.cancel();
    _incidentTimer = null;

    setState(() {
      _running = false;
    });
  }

  void _resetTimer() {
    _incidentTimer?.cancel();
    _incidentTimer = null;

    setState(() {
      _running = false;
      _incidentDuration = Duration.zero;
    });
  }

  String get timerText {
    final hours = _incidentDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_incidentDuration.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (_incidentDuration.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );

    return '$hours:$minutes:$seconds';
  }

  //----------------------------------------------------------
  // CPR RHYTHM
  //----------------------------------------------------------

  void _toggleCPRBeat() {
    if (_cprRunning) {
      _beatTimer?.cancel();
      _beatTimer = null;

      setState(() {
        _cprRunning = false;
        _pulse = false;
      });

      return;
    }

    final interval = Duration(milliseconds: (60000 / _cprBeat).round());

    setState(() {
      _cprRunning = true;
    });

    _beatTimer = Timer.periodic(interval, (_) {
      if (!mounted) return;

      setState(() {
        _cprBeatCount++;
        _pulse = !_pulse;
      });
    });
  }

  void _resetCPRBeat() {
    _beatTimer?.cancel();
    _beatTimer = null;

    setState(() {
      _cprRunning = false;
      _pulse = false;
      _cprBeatCount = 0;
    });
  }

  //----------------------------------------------------------
  // SOS FLASHLIGHT
  //----------------------------------------------------------

  Future<void> _toggleFlashlight() async {
    try {
      final isAvailable = await TorchLight.isTorchAvailable();

      if (!isAvailable) {
        throw Exception('Torch not available');
      }

      if (_flashlightOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }

      if (!mounted) return;

      setState(() {
        _flashlightOn = !_flashlightOn;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.flashlightUnavailable),
        ),
      );
    }
  }

  //----------------------------------------------------------
  // FORMAT TIMER
  //----------------------------------------------------------

  //----------------------------------------------------------
  // LIFECYCLE
  //----------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  @override
  void dispose() {
    _incidentTimer?.cancel();

    _beatTimer?.cancel();
    _turnOffFlashlightSilently();

    super.dispose();
  }

  //----------------------------------------------------------
  // BUILD
  //----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final card = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bg,

      //bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // Remaining UI comes in Part 2
              //----------------------------------------------------------
              // HEADER
              //----------------------------------------------------------
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textDark,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.mainShell,
                          (route) => false,
                          arguments: 0,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.bystanderAssist,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          t.offlineEmergencyAssistance,
                          style: TextStyle(
                            color: textSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              //----------------------------------------------------------
              // OFFLINE MODE CARD
              //----------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: successGreen,
                      size: 34,
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.offlineMode,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: successGreen,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            t.offlineModeDescription,
                            style: TextStyle(color: textSoft, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //----------------------------------------------------------
              // QUICK TOOLS
              //----------------------------------------------------------
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: primaryBlue,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t.incidentTimer,
                              style: TextStyle(
                                color: textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              timerText,
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),

                            const Text(
                              "HH        MM        SS",
                              style: TextStyle(
                                color: Color(0xFF71829E),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _running ? _pauseTimer : _startTimer,
                                icon: Icon(
                                  _running
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                label: Text(_running ? t.pause : t.start),
                                style: FilledButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _resetTimer,
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: Text(t.reset),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryBlue,
                                  minimumSize: const Size.fromHeight(48),
                                  side: const BorderSide(
                                    color: primaryBlue,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: _pulse ? 54 : 42,
                              width: _pulse ? 54 : 42,
                              decoration: const BoxDecoration(
                                color: dangerRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              t.cprBeat,
                              style: TextStyle(
                                color: textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              '$_cprBeat BPM',
                              style: const TextStyle(
                                color: dangerRed,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              '$_cprBeatCount',
                              style: const TextStyle(
                                color: dangerRed,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              t.cprBeatCount,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSoft,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _toggleCPRBeat,
                                icon: Icon(
                                  _cprRunning
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                label: Text(_cprRunning ? t.stop : t.start),
                                style: FilledButton.styleFrom(
                                  backgroundColor: dangerRed,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _resetCPRBeat,
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: Text(t.reset),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: dangerRed,
                                  minimumSize: const Size.fromHeight(48),
                                  side: const BorderSide(
                                    color: dangerRed,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // SOS FLASHLIGHT
              //----------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: warningOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flashlight_on_rounded,
                        color: warningOrange,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.sosFlashlight,
                            style: TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            t.sosFlashlightDescription,
                            style: TextStyle(color: textSoft, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: _flashlightOn,
                      activeColor: warningOrange,
                      onChanged: (_) {
                        _toggleFlashlight();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              //----------------------------------------------------------
              // SCENE MANAGEMENT
              //----------------------------------------------------------
              Text(
                t.takeChargeScene,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _SceneTimelineStep(
                      number: "1",
                      icon: Icons.self_improvement_rounded,
                      color: primaryBlue,
                      title: t.stayCalm,
                      subtitle: t.stayCalmDescription,
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "2",
                      icon: Icons.security_rounded,
                      color: successGreen,
                      title: t.ensureSceneSafety,
                      subtitle: t.ensureSceneSafetyDescription,
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "3",
                      icon: Icons.shield_rounded,
                      color: warningOrange,
                      title: t.protectYourself,
                      subtitle: t.protectYourselfDescription,
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "4",
                      icon: Icons.call_rounded,
                      color: dangerRed,
                      title: t.seekEmergencyHelp,
                      subtitle: t.seekEmergencyHelpDescription,
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "5",
                      icon: Icons.health_and_safety_rounded,
                      color: successGreen,
                      title: t.giveFirstAid,
                      subtitle: t.giveFirstAidDescription,
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "6",
                      icon: Icons.local_hospital_rounded,
                      color: primaryBlue,
                      title: t.waitForResponders,
                      subtitle: t.waitForRespondersDescription,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Text(
                t.emergencyFirstAidGuides,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 14),

              //----------------------------------------------------------
              // CPR
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.cprNotBreathing,
                icon: Icons.favorite_outline_rounded,
                iconColor: dangerRed,
                expanded: _cprExpanded,
                onTap: () {
                  setState(() {
                    _cprExpanded = !_cprExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.cprStep1),
                  _FirstAidStep(number: 2, text: t.cprStep2),
                  _FirstAidStep(number: 3, text: t.cprStep3),
                  _FirstAidStep(number: 4, text: t.cprStep4),
                  _FirstAidStep(number: 5, text: t.cprStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.cprWarning, color: dangerRed),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // SEVERE BLEEDING
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.severeBleeding,
                icon: Icons.bloodtype_rounded,
                iconColor: dangerRed,
                expanded: _bleedingExpanded,
                onTap: () {
                  setState(() {
                    _bleedingExpanded = !_bleedingExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.bleedingStep1),
                  _FirstAidStep(number: 2, text: t.bleedingStep2),
                  _FirstAidStep(number: 3, text: t.bleedingStep3),
                  _FirstAidStep(number: 4, text: t.bleedingStep4),
                  _FirstAidStep(number: 5, text: t.bleedingStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.bleedingWarning, color: dangerRed),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // CHOKING
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.choking,
                icon: Icons.air_rounded,
                iconColor: warningOrange,
                expanded: _chokingExpanded,
                onTap: () {
                  setState(() {
                    _chokingExpanded = !_chokingExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.chokingStep1),
                  _FirstAidStep(number: 2, text: t.chokingStep2),
                  _FirstAidStep(number: 3, text: t.chokingStep3),
                  _FirstAidStep(number: 4, text: t.chokingStep4),
                  _FirstAidStep(number: 5, text: t.chokingStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.chokingWarning, color: warningOrange),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // BURNS
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.burns,
                icon: Icons.local_fire_department_rounded,
                iconColor: warningOrange,
                expanded: _burnExpanded,
                onTap: () {
                  setState(() {
                    _burnExpanded = !_burnExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.burnsStep1),
                  _FirstAidStep(number: 2, text: t.burnsStep2),
                  _FirstAidStep(number: 3, text: t.burnsStep3),
                  _FirstAidStep(number: 4, text: t.burnsStep4),
                  _FirstAidStep(number: 5, text: t.burnsStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.burnsWarning, color: warningOrange),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // FRACTURE
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.fractureSpineInjury,
                icon: Icons.accessibility_new_rounded,
                iconColor: primaryBlue,
                expanded: _fractureExpanded,
                onTap: () {
                  setState(() {
                    _fractureExpanded = !_fractureExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.fractureStep1),
                  _FirstAidStep(number: 2, text: t.fractureStep2),
                  _FirstAidStep(number: 3, text: t.fractureStep3),
                  _FirstAidStep(number: 4, text: t.fractureStep4),
                  _FirstAidStep(number: 5, text: t.fractureStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.fractureWarning, color: dangerRed),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // SHOCK
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.shockUnconsciousBreathing,
                icon: Icons.monitor_heart_rounded,
                iconColor: successGreen,
                expanded: _shockExpanded,
                onTap: () {
                  setState(() {
                    _shockExpanded = !_shockExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.shockStep1),
                  _FirstAidStep(number: 2, text: t.shockStep2),
                  _FirstAidStep(number: 3, text: t.shockStep3),
                  _FirstAidStep(number: 4, text: t.shockStep4),
                  _FirstAidStep(number: 5, text: t.shockStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.shockWarning, color: warningOrange),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // POISONING
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.poisoning,
                icon: Icons.medication_liquid_rounded,
                iconColor: warningOrange,
                expanded: _poisonExpanded,
                onTap: () {
                  setState(() {
                    _poisonExpanded = !_poisonExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.poisoningStep1),
                  _FirstAidStep(number: 2, text: t.poisoningStep2),
                  _FirstAidStep(number: 3, text: t.poisoningStep3),
                  _FirstAidStep(number: 4, text: t.poisoningStep4),
                  _FirstAidStep(number: 5, text: t.poisoningStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.poisoningWarning, color: warningOrange),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // ELECTRIC SHOCK
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.electricShock,
                icon: Icons.electric_bolt_rounded,
                iconColor: warningOrange,
                expanded: _electricExpanded,
                onTap: () {
                  setState(() {
                    _electricExpanded = !_electricExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.electricStep1),
                  _FirstAidStep(number: 2, text: t.electricStep2),
                  _FirstAidStep(number: 3, text: t.electricStep3),
                  _FirstAidStep(number: 4, text: t.electricStep4),
                  _FirstAidStep(number: 5, text: t.electricStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.electricWarning, color: dangerRed),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // HEAT STROKE
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.heatStroke,
                icon: Icons.wb_sunny_rounded,
                iconColor: dangerRed,
                expanded: _heatExpanded,
                onTap: () {
                  setState(() {
                    _heatExpanded = !_heatExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.heatStep1),
                  _FirstAidStep(number: 2, text: t.heatStep2),
                  _FirstAidStep(number: 3, text: t.heatStep3),
                  _FirstAidStep(number: 4, text: t.heatStep4),
                  _FirstAidStep(number: 5, text: t.heatStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.heatWarning, color: dangerRed),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // DROWNING
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.drowning,
                icon: Icons.pool_rounded,
                iconColor: primaryBlue,
                expanded: _drowningExpanded,
                onTap: () {
                  setState(() {
                    _drowningExpanded = !_drowningExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.drowningStep1),
                  _FirstAidStep(number: 2, text: t.drowningStep2),
                  _FirstAidStep(number: 3, text: t.drowningStep3),
                  _FirstAidStep(number: 4, text: t.drowningStep4),
                  _FirstAidStep(number: 5, text: t.drowningStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.drowningWarning, color: primaryBlue),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // ANIMAL BITE
              //----------------------------------------------------------
              _FirstAidCard(
                title: t.animalBite,
                icon: Icons.pets_rounded,
                iconColor: successGreen,
                expanded: _animalExpanded,
                onTap: () {
                  setState(() {
                    _animalExpanded = !_animalExpanded;
                  });
                },
                children: [
                  _FirstAidStep(number: 1, text: t.animalBiteStep1),
                  _FirstAidStep(number: 2, text: t.animalBiteStep2),
                  _FirstAidStep(number: 3, text: t.animalBiteStep3),
                  _FirstAidStep(number: 4, text: t.animalBiteStep4),
                  _FirstAidStep(number: 5, text: t.animalBiteStep5),
                  const SizedBox(height: 16),
                  _InfoWarning(text: t.animalBiteWarning, color: successGreen),
                ],
              ),

              const SizedBox(height: 28),

              //----------------------------------------------------------
              // REPORT HISTORY
              //----------------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.history);
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: Text(t.viewEmergencyHistory),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryBlue,
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ], // <-- Column children ends
          ), // <-- Column ends
        ), // <-- SingleChildScrollView ends
      ), // <-- SafeArea ends
    ); // <-- Scaffold ends
  }
} // <-- build() method ends
//----------------------------------------------------------
// FIRST AID EXPANSION CARD
//----------------------------------------------------------

class _FirstAidCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool expanded;
  final VoidCallback onTap;
  final List<Widget> children;

  const _FirstAidCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.expanded,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final subText = isDark ? Colors.white70 : const Color(0xFF71829E);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          //------------------------------------------------
          // HEADER
          //------------------------------------------------
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: subText,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //------------------------------------------------
          // BODY
          //------------------------------------------------
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,

            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(children: children),
            ),

            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

//----------------------------------------------------------
// FIRST AID STEP
//----------------------------------------------------------

class _FirstAidStep extends StatelessWidget {
  final int number;
  final String text;

  const _FirstAidStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //------------------------------------------------
          // NUMBER
          //------------------------------------------------
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF2F6FE4),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(width: 14),

          //------------------------------------------------
          // DESCRIPTION
          //------------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//----------------------------------------------------------
// ASSIST STEP
//----------------------------------------------------------

class _AssistStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AssistStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //------------------------------------------------
        // STEP NUMBER
        //------------------------------------------------
        Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),

        const SizedBox(width: 16),

        //------------------------------------------------
        // ICON
        //------------------------------------------------
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),

        const SizedBox(width: 16),

        //------------------------------------------------
        // TEXT
        //------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                style: TextStyle(color: textSoft, fontSize: 14, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SceneTimelineStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isLast;

  const _SceneTimelineStep({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //========================================================
          // TIMELINE
          //========================================================
          SizedBox(
            width: 54,
            child: Column(
              children: [
                // Number + icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(icon, color: color, size: 22),

                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 19,
                          height: 19,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF162033)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          //========================================================
          // TEXT
          //========================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSoft,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//----------------------------------------------------------
// INFO / WARNING BOX
//----------------------------------------------------------

class _InfoWarning extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoWarning({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 24),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

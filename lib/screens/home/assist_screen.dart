import 'dart:async';

import 'package:flutter/material.dart';

import '../../routes.dart';
//import '../common/app_bottom_nav.dart';

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

  Timer? _timer;

  int _seconds = 0;

  bool _running = false;

  //----------------------------------------------------------
  // CPR METRONOME
  //----------------------------------------------------------

  bool _cprRunning = false;

  final int _cprBeat = 110;

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

  //----------------------------------------------------------
  // TIMER FUNCTIONS
  //----------------------------------------------------------

  void _startTimer() {
    if (_running) return;

    _running = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();

    _running = false;
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _seconds = 0;
      _running = false;
    });
  }

  //----------------------------------------------------------
  // CPR RHYTHM
  //----------------------------------------------------------

  void _toggleCPRBeat() {
    if (_cprRunning) {
      _beatTimer?.cancel();

      setState(() {
        _cprRunning = false;
        _pulse = false;
      });

      return;
    }

    _cprRunning = true;

    final interval = Duration(milliseconds: (60000 / _cprBeat).round());

    _beatTimer = Timer.periodic(interval, (_) {
      if (!mounted) return;

      setState(() {
        _pulse = !_pulse;
      });
    });
  }

  //----------------------------------------------------------
  // SOS FLASHLIGHT
  //----------------------------------------------------------

  void _toggleFlashlight() {
    setState(() {
      _flashlightOn = !_flashlightOn;
    });

    // TODO:
    // Integrate torch_light package later
    //
    // if(_flashlightOn){
    // TorchLight.enableTorch();
    // }else{
    // TorchLight.disableTorch();
    // }
  }

  //----------------------------------------------------------
  // FORMAT TIMER
  //----------------------------------------------------------

  String get timerText {
    final h = (_seconds ~/ 3600).toString().padLeft(2, '0');

    final m = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');

    final s = (_seconds % 60).toString().padLeft(2, '0');

    return "$h:$m:$s";
  }

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
    _timer?.cancel();

    _beatTimer?.cancel();

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
                          "Bystander Assist",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Offline Emergency Assistance",
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
                          const Text(
                            "Offline Mode",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: successGreen,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Emergency guidance is available without internet connection.",
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
              Row(
                children: [
                  //======================================================
                  // TIMER
                  //======================================================
                  //======================================================
                  // INCIDENT TIMER
                  //======================================================
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
                            "Incident Timer",
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

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                if (_running) {
                                  _stopTimer();
                                } else {
                                  _startTimer();
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryBlue,
                                minimumSize: const Size.fromHeight(42),
                              ),
                              child: Text(_running ? "Pause" : "Start"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //======================================================
                  // CPR METRONOME
                  //======================================================
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

                          const SizedBox(height: 14),

                          Text(
                            "CPR Beat",
                            style: TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "$_cprBeat BPM",
                            style: const TextStyle(
                              color: dangerRed,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 14),

                          FilledButton(
                            onPressed: _toggleCPRBeat,
                            style: FilledButton.styleFrom(
                              backgroundColor: dangerRed,
                              minimumSize: const Size.fromHeight(42),
                            ),
                            child: Text(_cprRunning ? "Stop" : "Start"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                            "SOS Flashlight",
                            style: TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Use your phone flashlight as an emergency signal.",
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
                "Take Charge of the Scene",
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
                      title: "Stay Calm",
                      subtitle:
                          "Remain calm and assess the emergency before taking action.",
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "2",
                      icon: Icons.security_rounded,
                      color: successGreen,
                      title: "Ensure Scene Safety",
                      subtitle:
                          "Check for fire, smoke, traffic, electricity, chemicals or other hazards.",
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "3",
                      icon: Icons.shield_rounded,
                      color: warningOrange,
                      title: "Protect Yourself",
                      subtitle:
                          "Never become another victim. Enter only if it is safe.",
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "4",
                      icon: Icons.call_rounded,
                      color: dangerRed,
                      title: "Call 999",
                      subtitle:
                          "Contact emergency services immediately if the situation is life-threatening.",
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "5",
                      icon: Icons.health_and_safety_rounded,
                      color: successGreen,
                      title: "Give First Aid",
                      subtitle:
                          "Provide first aid only if you know how and it is safe.",
                      isLast: false,
                    ),

                    _SceneTimelineStep(
                      number: "6",
                      icon: Icons.local_hospital_rounded,
                      color: primaryBlue,
                      title: "Wait for Responders",
                      subtitle:
                          "Continue monitoring the victim until professional responders arrive.",
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              Text(
                "Emergency First Aid Guides",
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
                title: "CPR — Not Breathing",
                icon: Icons.favorite_outline_rounded,
                iconColor: dangerRed,
                expanded: _cprExpanded,
                onTap: () {
                  setState(() {
                    _cprExpanded = !_cprExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text: "Check response — tap shoulders, shout loudly",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text: "Ask someone to call 999 and get an AED",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "Place heel of hand on centre of the chest, other hand on top",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Push hard and fast, 5–6 cm deep, 100–120 compressions per minute",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Do not stop until the victim moves or professional help arrives",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Only perform CPR if the victim is unresponsive and not breathing normally.",
                    color: dangerRed,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // SEVERE BLEEDING
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Severe Bleeding",
                icon: Icons.bloodtype_rounded,
                iconColor: dangerRed,
                expanded: _bleedingExpanded,
                onTap: () {
                  setState(() {
                    _bleedingExpanded = !_bleedingExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Apply firm direct pressure to the wound immediately using a clean cloth, sterile dressing or your hand if nothing else is available.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Keep continuous pressure on the wound. Do not repeatedly remove the dressing to check the bleeding.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "If blood soaks through, place another dressing on top and continue applying pressure.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Raise the injured arm or leg above the level of the heart if there is no suspected fracture.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Call 999 immediately if bleeding cannot be controlled or is life-threatening.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Never remove objects deeply embedded in a wound. Apply pressure around the object and wait for emergency responders.",
                    color: dangerRed,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // CHOKING
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Choking",
                icon: Icons.air_rounded,
                iconColor: warningOrange,
                expanded: _chokingExpanded,
                onTap: () {
                  setState(() {
                    _chokingExpanded = !_chokingExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Ask the victim if they are choking. If they can cough or speak, encourage them to keep coughing.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "If they cannot cough, speak or breathe, stand slightly behind them and give up to 5 firm back blows between the shoulder blades.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "If the object does not come out, give up to 5 abdominal thrusts (Heimlich manoeuvre) for adults and children over 1 year old.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Continue alternating 5 back blows and 5 abdominal thrusts until the blockage is removed or the victim becomes unconscious.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "If the victim becomes unconscious, call 999 immediately and begin CPR if they are not breathing normally.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Do NOT perform abdominal thrusts on infants under 1 year old or pregnant individuals. Use the appropriate first aid technique instead.",
                    color: warningOrange,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // BURNS
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Burns",
                icon: Icons.local_fire_department_rounded,
                iconColor: warningOrange,
                expanded: _burnExpanded,
                onTap: () {
                  setState(() {
                    _burnExpanded = !_burnExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Move the victim away from the heat source if it is safe to do so.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Cool the burned area under cool running water for at least 20 minutes.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "Remove rings, watches and tight clothing before swelling begins, but do not remove anything stuck to the burn.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Cover the burn with a sterile non-stick dressing or clean plastic wrap.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Seek emergency medical care for deep, chemical, electrical or large burns.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Do NOT apply toothpaste, butter, oils, creams or ice directly onto a burn.",
                    color: warningOrange,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // FRACTURE
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Fracture / Spine Injury",
                icon: Icons.accessibility_new_rounded,
                iconColor: primaryBlue,
                expanded: _fractureExpanded,
                onTap: () {
                  setState(() {
                    _fractureExpanded = !_fractureExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Tell the victim to remain still and avoid moving the injured body part.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Support the injured limb using towels, clothing or a splint if available.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "Apply a wrapped ice pack to reduce swelling. Never place ice directly on the skin.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "If a spinal injury is suspected, keep the head, neck and back aligned. Do not move the victim unless there is immediate danger.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Call 999 if there is severe pain, deformity, heavy bleeding or suspected spinal injury.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Do NOT attempt to straighten broken bones or move someone with a suspected spinal injury.",
                    color: primaryBlue,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // SHOCK
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Shock / Unconscious but Breathing",
                icon: Icons.monitor_heart_rounded,
                iconColor: successGreen,
                expanded: _shockExpanded,
                onTap: () {
                  setState(() {
                    _shockExpanded = !_shockExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Lay the victim flat on their back unless an injury prevents it.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Raise the legs about 30 cm if there are no head, spine or leg injuries.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "Loosen tight clothing and keep the victim warm using a blanket or jacket.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "If unconscious but breathing normally, place the victim into the recovery position.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Monitor breathing continuously until emergency responders arrive.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Do NOT give food, drinks or medication to an unconscious person.",
                    color: successGreen,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // POISONING
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Poisoning",
                icon: Icons.medication_liquid_rounded,
                iconColor: warningOrange,
                expanded: _poisonExpanded,
                onTap: () {
                  setState(() {
                    _poisonExpanded = !_poisonExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Move the victim away from the poisonous substance if it is safe.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Identify the poison if possible and keep the container for medical personnel.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "If poison is on the skin or eyes, rinse continuously with clean water.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Call 999 immediately if the victim is unconscious, has difficulty breathing or has seizures.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Follow instructions from emergency responders while waiting for help.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Do NOT force the victim to vomit unless instructed by medical professionals.",
                    color: warningOrange,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // ELECTRIC SHOCK
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Electric Shock",
                icon: Icons.electric_bolt_rounded,
                iconColor: warningOrange,
                expanded: _electricExpanded,
                onTap: () {
                  setState(() {
                    _electricExpanded = !_electricExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Switch off the electricity source before touching the victim.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "If you cannot switch it off, use a dry wooden or plastic object to separate the victim from the source.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "Call 999 immediately even if the victim appears to be well.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Check breathing and begin CPR if the victim is not breathing normally.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Cover any burns with a sterile dressing while waiting for help.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Never touch a victim while they are still in contact with electricity.",
                    color: warningOrange,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // HEAT STROKE
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Heat Stroke",
                icon: Icons.wb_sunny_rounded,
                iconColor: dangerRed,
                expanded: _heatExpanded,
                onTap: () {
                  setState(() {
                    _heatExpanded = !_heatExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Move the victim to a cool or shaded area immediately.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Remove excess clothing and cool the body using wet towels or cool water.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text: "Fan the victim to help reduce body temperature.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "If the victim is conscious, offer cool drinking water slowly.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Call 999 if the victim becomes confused, collapses or loses consciousness.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Heat stroke is a medical emergency. Rapid cooling is essential.",
                    color: dangerRed,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // DROWNING
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Drowning",
                icon: Icons.pool_rounded,
                iconColor: primaryBlue,
                expanded: _drowningExpanded,
                onTap: () {
                  setState(() {
                    _drowningExpanded = !_drowningExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Remove the victim from the water only if it is safe.",
                  ),

                  _FirstAidStep(number: 2, text: "Call 999 immediately."),

                  _FirstAidStep(
                    number: 3,
                    text:
                        "Check breathing. Begin CPR if the victim is not breathing normally.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Keep the victim warm with a blanket or dry clothing.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Continue monitoring until emergency responders arrive.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Do NOT attempt to remove water from the lungs before starting CPR.",
                    color: primaryBlue,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //----------------------------------------------------------
              // ANIMAL BITE
              //----------------------------------------------------------
              _FirstAidCard(
                title: "Animal Bite",
                icon: Icons.pets_rounded,
                iconColor: successGreen,
                expanded: _animalExpanded,
                onTap: () {
                  setState(() {
                    _animalExpanded = !_animalExpanded;
                  });
                },
                children: const [
                  _FirstAidStep(
                    number: 1,
                    text:
                        "Wash the wound thoroughly with soap and clean running water for several minutes.",
                  ),

                  _FirstAidStep(
                    number: 2,
                    text:
                        "Control bleeding by applying gentle pressure with a clean dressing.",
                  ),

                  _FirstAidStep(
                    number: 3,
                    text: "Cover the wound using a sterile bandage.",
                  ),

                  _FirstAidStep(
                    number: 4,
                    text:
                        "Seek medical attention for deep wounds, wild animal bites or possible rabies exposure.",
                  ),

                  _FirstAidStep(
                    number: 5,
                    text:
                        "Monitor the victim for signs of infection while waiting for treatment.",
                  ),

                  SizedBox(height: 16),

                  _InfoWarning(
                    text:
                        "Animal bites can lead to serious infection. Medical assessment is recommended.",
                    color: successGreen,
                  ),
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
                  label: const Text("View Emergency History"),
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

                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: color.withValues(alpha: 0.20),
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

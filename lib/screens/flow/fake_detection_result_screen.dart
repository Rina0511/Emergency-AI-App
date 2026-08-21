import 'dart:io';

import 'package:flutter/material.dart';

import '../../routes.dart';

class FakeDetectionResultScreen extends StatelessWidget {
  const FakeDetectionResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String? imagePath = args?['imagePath'];

    final bool isSuspicious = args?['isSuspicious'] ?? true;

    final double confidence = args?['confidence'] ?? 72;

    final List<String> reasons =
        args?['reasons'] ??
        [
          'Image metadata unavailable',
          'Possible editing detected',
          'Image authenticity needs verification',
        ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    const dangerRed = Color(0xFFE12529);

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

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
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: textDark,
                        size: 18,
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "Image Verification Result",

                    style: TextStyle(
                      fontSize: 18,

                      fontWeight: FontWeight.w800,

                      color: textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              if (imagePath != null)
                Container(
                  height: 220,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),

                    image: DecorationImage(
                      image: FileImage(File(imagePath)),

                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  children: [
                    Icon(
                      isSuspicious
                          ? Icons.warning_amber_rounded
                          : Icons.verified_outlined,

                      size: 60,

                      color: isSuspicious ? dangerRed : Colors.green,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isSuspicious
                          ? "Suspicious Image"
                          : "Image Appears Authentic",

                      style: TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.w900,

                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Detection confidence: ${confidence.toStringAsFixed(0)}%",

                      style: TextStyle(color: textSoft, fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Verification Details",

                      style: TextStyle(
                        fontSize: 17,

                        fontWeight: FontWeight.w800,

                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...reasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,

                              color: primaryBlue,

                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                reason,

                                style: TextStyle(color: textSoft),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.reportRole);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,

                  padding: const EdgeInsets.symmetric(vertical: 17),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Continue Emergency Report",

                  style: TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

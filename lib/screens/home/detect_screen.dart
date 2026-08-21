import 'package:flutter/material.dart';
import '../../routes.dart';

class DetectScreen extends StatelessWidget {
  const DetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Text(
                "Fake Image Detection",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Check whether an emergency image may be manipulated or unreliable before making a decision.",

                style: TextStyle(color: textSoft, fontSize: 15),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.image_search,
                      size: 80,
                      color: primaryBlue,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Upload Image For Checking",

                      style: TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.w800,

                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,

                          AppRoutes.fakeDetectionUpload,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                      ),

                      child: const Text(
                        "Select Image",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

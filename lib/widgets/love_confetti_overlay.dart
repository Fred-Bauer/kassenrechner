import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// Full-screen confetti layer used for the love easter egg.
class LoveConfettiOverlay extends StatelessWidget {
  const LoveConfettiOverlay({
    super.key,
    required this.controller,
  });

  final ConfettiController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 1.0,
            numberOfParticles: 24,
            maxBlastForce: 26,
            minBlastForce: 10,
            gravity: 0.18,
            shouldLoop: false,
            colors: const [
              Color(0xFFE91E1E),
              Color(0xFFE91E63),
              Color(0xFFFF80AB),
              //Color(0xFFFFC107),
              Color(0xFF4CAF50),
              //Color(0xFF03A9F4),
            ],
          ),
        ),
      ),
    );
  }
}

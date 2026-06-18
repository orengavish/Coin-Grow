import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';

class OutcomeScreen extends StatelessWidget {
  final SceneModel scene;
  final int totalPoints;
  final int happinessLevel;
  final VoidCallback onAdvance;

  const OutcomeScreen({
    super.key,
    required this.scene,
    required this.totalPoints,
    required this.happinessLevel,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final outcome = scene.outcome;
    final points = outcome?.pointsAwarded ?? 0;
    final happiness = outcome?.happinessDelta ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HappinessMeter(level: happinessLevel + happiness),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.gold, width: 2),
                ),
                child: Text(
                  outcome?.narrativeResult ?? scene.narrative,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (points > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '+$points points',
                    style: const TextStyle(
                      color: AppTheme.darkNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAdvance,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HappinessMeter extends StatelessWidget {
  final int level;

  const _HappinessMeter({required this.level});

  @override
  Widget build(BuildContext context) {
    final clamped = level.clamp(-3, 3);
    final emoji = switch (clamped) {
      3 => '😄',
      2 => '😊',
      1 => '🙂',
      0 => '😐',
      -1 => '😟',
      -2 => '😢',
      _ => '😭',
    };
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 8),
        const Text(
          'Family happiness',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }
}

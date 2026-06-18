import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';

// Placeholder portrait — replace with Rive animation when art assets are ready.
// The `emotion` string maps directly to Rive state machine inputs.
class CharacterPortrait extends StatelessWidget {
  final CharacterModel character;
  final String emotion;

  const CharacterPortrait({super.key, required this.character, required this.emotion});

  IconData get _emotionIcon => switch (emotion) {
        'excited' || 'happy' => Icons.sentiment_very_satisfied,
        'sad' || 'upset' => Icons.sentiment_very_dissatisfied,
        'skeptical' || 'suspicious' => Icons.sentiment_neutral,
        'urgent' || 'worried' => Icons.sentiment_dissatisfied,
        _ => Icons.sentiment_satisfied,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withOpacity(0.15),
              border: Border.all(color: AppTheme.gold, width: 2),
            ),
            child: Icon(_emotionIcon, size: 44, color: AppTheme.gold),
          ),
          const SizedBox(height: 4),
          Text(
            character.name,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

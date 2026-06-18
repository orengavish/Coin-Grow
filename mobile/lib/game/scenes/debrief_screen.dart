import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';

class DebriefScreen extends StatelessWidget {
  final SceneModel scene;
  final DebriefModel debrief;
  final ScoringModel scoring;
  final int totalPoints;
  final VoidCallback onFinish;

  const DebriefScreen({
    super.key,
    required this.scene,
    required this.debrief,
    required this.scoring,
    required this.totalPoints,
    required this.onFinish,
  });

  String get _grade {
    final thresholds = scoring.gradeThresholds ?? {};
    if (totalPoints >= (thresholds['gold'] ?? 80)) return 'gold';
    if (totalPoints >= (thresholds['silver'] ?? 50)) return 'silver';
    return 'bronze';
  }

  @override
  Widget build(BuildContext context) {
    final trophy = scoring.trophy;
    final grade = _grade;

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                switch (grade) { 'gold' => '🥇', 'silver' => '🥈', _ => '🥉' },
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 8),
              Text(
                trophy.name,
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                trophy.unlockMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalPoints / ${scoring.maxPoints} points',
                style: const TextStyle(color: AppTheme.gold, fontSize: 18),
              ),
              const SizedBox(height: 32),
              _InfoCard(
                title: '💡 ${debrief.conceptName}',
                body: debrief.conceptExplanation,
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: '🌍 Real world',
                body: debrief.realWorldConnection,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.forestGreen),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🗣 Discussion question',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      debrief.reflectionQuestion,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Next up: ${debrief.teaserNextLesson}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onFinish,
                child: const Text('Back to lessons'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(color: AppTheme.lightText, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

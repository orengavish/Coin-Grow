import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';
import '../widgets/narrative_box.dart';

class DeadEndScreen extends StatelessWidget {
  final DeadEndBlock deadEnd;
  final String owlName;
  final VoidCallback onDismiss;

  const DeadEndScreen({
    super.key,
    required this.deadEnd,
    required this.owlName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Visual area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: AppTheme.deepBlue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🚫', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        deadEnd.visualDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NarrativeBox(text: deadEnd.narrative.text),
                    const SizedBox(height: 12),
                    // Micro-lesson
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.skyBlue.withValues(alpha:0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡  Lesson learned',
                            style: TextStyle(
                              color: AppTheme.skyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            deadEnd.microLesson.text,
                            style: const TextStyle(
                              color: AppTheme.lightText,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Owl response
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.gold.withValues(alpha:0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🦉 ',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                owlName,
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            deadEnd.owlResponse.text,
                            style: const TextStyle(
                              color: AppTheme.lightText,
                              fontSize: 14,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onDismiss,
                        child: const Text('Back to the market'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

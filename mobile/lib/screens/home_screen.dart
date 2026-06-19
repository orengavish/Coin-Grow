import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';
import 'cinematic_intro_screen.dart';
import 'lesson_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<LessonModel> _loadLesson() async {
    final raw = await rootBundle
        .loadString('assets/lessons/lesson_01_the_orange_quest.json');
    return LessonModel.fromJson(jsonDecode(raw));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'Coin Grow',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Learn money by living it.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '🦉  Prof Penny is waiting',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final lesson = await _loadLesson();
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CinematicIntroScreen(
                          onComplete: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonPlayer(
                                lesson: lesson,
                                onComplete: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load lesson: $e'),
                          backgroundColor: Colors.red[800],
                        ),
                      );
                    }
                  }
                },
                child: const Text('▶  The Orange Quest'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'More lessons coming soon',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

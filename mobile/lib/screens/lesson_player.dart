import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../game/scenes/scene_router.dart';

// Drives the entire lesson from first scene to completion.
// Maintains scene index, points, and happiness state.
class LessonPlayer extends StatefulWidget {
  final LessonModel lesson;
  final VoidCallback onComplete;

  const LessonPlayer({super.key, required this.lesson, required this.onComplete});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  late String _currentSceneId;
  int _totalPoints = 0;
  int _happinessLevel = 0;

  Map<String, SceneModel> get _sceneMap =>
      {for (var s in widget.lesson.scenes) s.id: s};

  @override
  void initState() {
    super.initState();
    _currentSceneId = widget.lesson.scenes.first.id;
  }

  void _advance(String nextSceneId, {int? points, int? happiness}) {
    if (nextSceneId == '__lesson_complete__') {
      widget.onComplete();
      return;
    }
    setState(() {
      _currentSceneId = nextSceneId;
      if (points != null) _totalPoints += points;
      if (happiness != null) _happinessLevel = (_happinessLevel + happiness).clamp(-3, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scene = _sceneMap[_currentSceneId];
    if (scene == null) {
      return const Scaffold(
        body: Center(child: Text('Scene not found', style: TextStyle(color: Colors.red))),
      );
    }

    return buildScene(
      scene: scene,
      lesson: widget.lesson,
      totalPoints: _totalPoints,
      happinessLevel: _happinessLevel,
      onAdvance: _advance,
    );
  }
}

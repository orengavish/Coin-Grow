import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import 'cutscene_screen.dart';
import 'dialogue_screen.dart';
import 'choice_screen.dart';
import 'outcome_screen.dart';
import 'debrief_screen.dart';

// Routes a SceneModel to the correct screen widget based on scene type.
// The LessonPlayer calls this after every scene transition.
Widget buildScene({
  required SceneModel scene,
  required LessonModel lesson,
  required int totalPoints,
  required int happinessLevel,
  required void Function(String nextSceneId, {int? points, int? happiness}) onAdvance,
}) {
  final characters = {for (var c in lesson.characters) c.id: c};

  return switch (scene.type) {
    SceneType.cutscene || SceneType.dialogue => DialogueScreen(
        scene: scene,
        characters: characters,
        onAdvance: () => onAdvance(scene.leadsTo ?? ''),
      ),
    SceneType.choice => ChoiceScreen(
        scene: scene,
        characters: characters,
        onChoose: (choice) => onAdvance(
          choice.leadsToScene,
          points: 0,
        ),
      ),
    SceneType.outcome => OutcomeScreen(
        scene: scene,
        totalPoints: totalPoints,
        happinessLevel: happinessLevel,
        onAdvance: () => onAdvance(
          scene.leadsTo ?? '',
          points: scene.outcome?.pointsAwarded ?? 0,
          happiness: scene.outcome?.happinessDelta ?? 0,
        ),
      ),
    SceneType.debrief => DebriefScreen(
        scene: scene,
        debrief: lesson.debrief,
        scoring: lesson.scoring,
        totalPoints: totalPoints,
        onFinish: () => onAdvance('__lesson_complete__'),
      ),
    _ => CutsceneScreen(
        scene: scene,
        onAdvance: () => onAdvance(scene.leadsTo ?? ''),
      ),
  };
}

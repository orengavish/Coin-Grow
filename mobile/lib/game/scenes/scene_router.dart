import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import 'cutscene_screen.dart';
import 'dialogue_screen.dart';
import 'debrief_screen.dart';

Widget buildScene({
  required SceneModel scene,
  required LessonModel lesson,
  required int totalPoints,
  required VoidCallback onAdvance,
}) {
  if (scene.type == SceneType.debrief) {
    return DebriefScreen(
      scene: scene,
      debrief: lesson.debrief,
      scoring: lesson.scoring,
      totalPoints: totalPoints,
      onFinish: onAdvance,
    );
  }

  if (scene.npcDialogue.isEmpty) {
    return CutsceneScreen(scene: scene, onAdvance: onAdvance);
  }

  return DialogueScreen(
    scene: scene,
    characters: lesson.characters,
    onAdvance: onAdvance,
  );
}

import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';
import '../../widgets/narrative_box.dart';

class CutsceneScreen extends StatelessWidget {
  final SceneModel scene;
  final VoidCallback onAdvance;

  const CutsceneScreen({super.key, required this.scene, required this.onAdvance});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdvance,
      child: Scaffold(
        backgroundColor: AppTheme.darkBrown,
        body: SafeArea(
          child: Column(
            children: [
              // Scene illustration placeholder (replace with actual art/Rive)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: AppTheme.parchment.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.landscape, size: 80, color: Colors.white30),
                      const SizedBox(height: 8),
                      Text(
                        scene.visualDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              // Narrative box
              Expanded(
                flex: 2,
                child: NarrativeBox(
                  text: scene.narrative,
                  onTap: onAdvance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

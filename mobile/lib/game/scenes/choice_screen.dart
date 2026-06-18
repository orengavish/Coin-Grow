import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';
import '../../widgets/narrative_box.dart';

class ChoiceScreen extends StatelessWidget {
  final SceneModel scene;
  final Map<String, CharacterModel> characters;
  final void Function(ChoiceModel choice) onChoose;

  const ChoiceScreen({
    super.key,
    required this.scene,
    required this.characters,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: AppTheme.deepBlue,
                child: const Icon(Icons.help_outline, size: 64, color: Colors.white24),
              ),
            ),
            NarrativeBox(text: scene.narrative, onTap: null),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'What do you do?',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...scene.choices.map((choice) => _ChoiceButton(
                          choice: choice,
                          onTap: () => onChoose(choice),
                        )),
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

class _ChoiceButton extends StatelessWidget {
  final ChoiceModel choice;
  final VoidCallback onTap;

  const _ChoiceButton({required this.choice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.deepBlue,
            foregroundColor: AppTheme.lightText,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: AppTheme.gold.withOpacity(0.5)),
          ),
          child: Text(
            choice.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

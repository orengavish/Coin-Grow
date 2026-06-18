import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';
import '../../widgets/narrative_box.dart';
import '../../widgets/character_portrait.dart';

class DialogueScreen extends StatefulWidget {
  final SceneModel scene;
  final Map<String, CharacterModel> characters;
  final VoidCallback onAdvance;

  const DialogueScreen({
    super.key,
    required this.scene,
    required this.characters,
    required this.onAdvance,
  });

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  int _dialogueIndex = 0;

  void _next() {
    if (_dialogueIndex < widget.scene.npcDialogue.length - 1) {
      setState(() => _dialogueIndex++);
    } else {
      widget.onAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.scene.npcDialogue;
    final hasDialogue = lines.isNotEmpty;
    final currentLine = hasDialogue ? lines[_dialogueIndex] : null;
    final speaker = currentLine != null ? widget.characters[currentLine.characterId] : null;

    return Scaffold(
      backgroundColor: AppTheme.darkBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Scene background placeholder
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppTheme.parchment.withOpacity(0.08),
                    child: const Icon(Icons.landscape, size: 80, color: Colors.white12),
                  ),
                  if (speaker != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CharacterPortrait(
                        character: speaker,
                        emotion: currentLine?.emotion ?? 'neutral',
                      ),
                    ),
                ],
              ),
            ),
            // Dialogue / narrative box
            Expanded(
              flex: 2,
              child: currentLine != null
                  ? GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.parchment,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.gold, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (speaker != null)
                              Text(
                                speaker.name,
                                style: TextStyle(
                                  color: AppTheme.darkBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                currentLine.line,
                                style: const TextStyle(
                                  color: AppTheme.darkBrown,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '${_dialogueIndex + 1} / ${lines.length}  ▶',
                                style: TextStyle(color: AppTheme.darkBrown.withOpacity(0.5), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : NarrativeBox(text: widget.scene.narrative, onTap: _next),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _DialogueScreenState extends State<DialogueScreen>
    with SingleTickerProviderStateMixin {
  int _lineIndex = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() async {
    if (_lineIndex < widget.scene.npcDialogue.length - 1) {
      await _fadeCtrl.reverse();
      setState(() => _lineIndex++);
      _fadeCtrl.forward();
    } else {
      widget.onAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.scene.npcDialogue;
    final currentLine = lines.isNotEmpty ? lines[_lineIndex] : null;
    final speaker =
        currentLine != null ? widget.characters[currentLine.characterId] : null;

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppTheme.deepBlue,
                  ),
                  if (speaker != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: CharacterPortrait(
                          character: speaker,
                          emotion: currentLine?.emotion ?? 'neutral',
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
                          color: AppTheme.deepBlue,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.gold, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (speaker != null)
                              Text(
                                speaker.name,
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: FadeTransition(
                                opacity: _fadeAnim,
                                child: Text(
                                  currentLine.line.text,
                                  style: const TextStyle(
                                    color: AppTheme.lightText,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '${_lineIndex + 1} / ${lines.length}  ▶',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : NarrativeBox(
                      text: widget.scene.narrative.text, onTap: _next),
            ),
          ],
        ),
      ),
    );
  }
}

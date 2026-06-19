import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';
import '../../widgets/narrative_box.dart';
import '../../widgets/character_portrait.dart';

class CutsceneScreen extends StatefulWidget {
  final SceneModel scene;
  final LessonModel? lesson;
  final VoidCallback onAdvance;

  const CutsceneScreen({
    super.key,
    required this.scene,
    this.lesson,
    required this.onAdvance,
  });

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  CharacterModel? get _owlCharacter =>
      widget.lesson?.characters['owl'];

  @override
  Widget build(BuildContext context) {
    final owl = _owlCharacter;

    return GestureDetector(
      onTap: widget.onAdvance,
      child: Scaffold(
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
                    if (owl != null)
                      Positioned(
                        bottom: 0,
                        right: 24,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: CharacterPortrait(
                            character: owl,
                            emotion: 'wave',
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Text(
                        widget.scene.visualDescription,
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: NarrativeBox(
                  text: widget.scene.narrative.text,
                  onTap: widget.onAdvance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

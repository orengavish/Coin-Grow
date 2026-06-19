import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../game/scenes/scene_router.dart';
import 'path_selection_screen.dart';
import 'dead_end_screen.dart';

enum _Zone { intro, pathSelect, pathScenes, ending }

class LessonPlayer extends StatefulWidget {
  final LessonModel lesson;
  final VoidCallback onComplete;

  const LessonPlayer({super.key, required this.lesson, required this.onComplete});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  _Zone _zone = _Zone.intro;
  int _introIndex = 0;
  PathModel? _selectedPath;
  int _pathSceneIndex = 0;
  int _endingIndex = 0;
  int _totalPoints = 0;
  final Set<String> _triedDeadEnds = {};
  PathModel? _activeDeadEnd;

  String get _owlName =>
      widget.lesson.characters['owl']?.name ?? 'Prof Penny';

  void _onIntroAdvance() {
    if (_introIndex < widget.lesson.introScenes.length - 1) {
      setState(() => _introIndex++);
    } else {
      setState(() => _zone = _Zone.pathSelect);
    }
  }

  void _onPathSelected(PathModel path) {
    if (path.isDeadEnd) {
      setState(() {
        _triedDeadEnds.add(path.id);
        _activeDeadEnd = path;
      });
    } else {
      final pts = widget.lesson.scoring.pathPoints[path.id] ?? 0;
      setState(() {
        _selectedPath = path;
        _pathSceneIndex = 0;
        _totalPoints += pts;
        _zone = _Zone.pathScenes;
        _activeDeadEnd = null;
      });
    }
  }

  void _onDeadEndDismissed() {
    setState(() => _activeDeadEnd = null);
  }

  void _onPathSceneAdvance() {
    final path = _selectedPath!;
    if (_pathSceneIndex < path.scenes.length - 1) {
      setState(() => _pathSceneIndex++);
    } else {
      setState(() {
        _zone = _Zone.ending;
        _endingIndex = 0;
      });
    }
  }

  void _onEndingAdvance() {
    if (_endingIndex < widget.lesson.endingScenes.length - 1) {
      setState(() => _endingIndex++);
    } else {
      widget.onComplete();
    }
  }

  Widget _currentChild() => switch (_zone) {
        _Zone.intro => buildScene(
            scene: widget.lesson.introScenes[_introIndex],
            lesson: widget.lesson,
            totalPoints: _totalPoints,
            onAdvance: _onIntroAdvance,
          ),
        _Zone.pathSelect => _activeDeadEnd != null
            ? DeadEndScreen(
                key: ValueKey('dead_${_activeDeadEnd!.id}'),
                deadEnd: _activeDeadEnd!.deadEnd!,
                owlName: _owlName,
                onDismiss: _onDeadEndDismissed,
              )
            : PathSelectionScreen(
                key: const ValueKey('pathSelect'),
                paths: widget.lesson.paths,
                triedDeadEnds: _triedDeadEnds,
                onSelect: _onPathSelected,
              ),
        _Zone.pathScenes => buildScene(
            scene: _selectedPath!.scenes[_pathSceneIndex],
            lesson: widget.lesson,
            totalPoints: _totalPoints,
            onAdvance: _onPathSceneAdvance,
          ),
        _Zone.ending => buildScene(
            scene: widget.lesson.endingScenes[_endingIndex],
            lesson: widget.lesson,
            totalPoints: _totalPoints,
            onAdvance: _onEndingAdvance,
          ),
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: child,
      ),
      child: KeyedSubtree(
        key: ValueKey('${_zone}_${_introIndex}_${_pathSceneIndex}_${_endingIndex}_${_activeDeadEnd?.id}'),
        child: _currentChild(),
      ),
    );
  }
}

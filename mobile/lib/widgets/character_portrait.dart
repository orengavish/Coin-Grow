import 'package:flutter/material.dart';
import '../models/lesson.dart';

class CharacterPortrait extends StatefulWidget {
  final CharacterModel character;
  final String emotion;

  const CharacterPortrait({super.key, required this.character, required this.emotion});

  @override
  State<CharacterPortrait> createState() => _CharacterPortraitState();
}

class _CharacterPortraitState extends State<CharacterPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;
  late final Animation<double> _bobAnim;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bob, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  String get _assetPath {
    final id = widget.character.id;
    if (id == 'owl') {
      return switch (widget.emotion) {
        'excited' || 'happy' || 'celebrate' => 'assets/images/penny-celebrate.png',
        'thinking' || 'skeptical' || 'thoughtful' => 'assets/images/penny-thoughtful.png',
        _ => 'assets/images/penny-wave.png',
      };
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final path = _assetPath;
    final isOwl = widget.character.id == 'owl';

    return AnimatedBuilder(
      animation: _bobAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bobAnim.value),
        child: child,
      ),
      child: isOwl && path.isNotEmpty
          ? Image.asset(path, height: 180, fit: BoxFit.contain)
          : _FallbackPortrait(name: widget.character.name),
    );
  }
}

class _FallbackPortrait extends StatelessWidget {
  final String name;
  const _FallbackPortrait({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white10,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: const Icon(Icons.person, size: 44, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

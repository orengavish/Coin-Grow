import 'package:flutter/material.dart';

enum _Scene { room, healer, grief, rise }

class _Line {
  final String? speaker;
  final String text;
  const _Line(this.text, {this.speaker});
}

class _Beat {
  final _Scene scene;
  final List<_Line> lines;
  const _Beat(this.scene, this.lines);
}

const _beats = [
  _Beat(_Scene.room, [
    _Line('The village sleeps.'),
    _Line('But not Luca.'),
    _Line('Your little brother burns with fever.'),
  ]),
  _Beat(_Scene.healer, [
    _Line('I have done what I can.', speaker: 'The Healer'),
    _Line('If Luca does not eat an orange before dawn...', speaker: 'The Healer'),
    _Line('He will die.', speaker: 'The Healer'),
  ]),
  _Beat(_Scene.grief, [
    _Line('Your mother presses her face into her hands.'),
    _Line('Your father stares at the floor.'),
    _Line('No one moves.'),
  ]),
  _Beat(_Scene.rise, [
    _Line('You stand up.'),
    _Line('I will get it.', speaker: 'Eli'),
  ]),
];

class CinematicIntroScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const CinematicIntroScreen({super.key, required this.onComplete});

  @override
  State<CinematicIntroScreen> createState() => _CinematicIntroState();
}

class _CinematicIntroState extends State<CinematicIntroScreen>
    with TickerProviderStateMixin {
  int _beatIndex = 0;
  int _lineIndex = 0;

  late AnimationController _typeCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _sceneCtrl;

  _Beat get _beat => _beats[_beatIndex];
  _Line get _line => _beat.lines[_lineIndex];
  bool get _isTyping => _typeCtrl.value < 1.0;

  int _charCount = 0;

  @override
  void initState() {
    super.initState();

    _sceneCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0,
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _typeCtrl = AnimationController(
      vsync: this,
      duration: _typeDuration(_line.text),
    )..addListener(() {
        setState(() {
          _charCount = (_typeCtrl.value * _line.text.length).floor();
        });
      });

    _typeCtrl.forward();
  }

  Duration _typeDuration(String text) =>
      Duration(milliseconds: (text.length * 38).clamp(600, 3000));

  @override
  void dispose() {
    _typeCtrl.dispose();
    _fadeCtrl.dispose();
    _sceneCtrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (_isTyping) {
      _typeCtrl.stop();
      setState(() => _charCount = _line.text.length);
      return;
    }

    final isLastLine = _lineIndex == _beat.lines.length - 1;
    final isLastBeat = _beatIndex == _beats.length - 1;

    if (isLastLine && isLastBeat) {
      widget.onComplete();
      return;
    }

    if (!isLastLine) {
      // Fade text out, advance line, fade back in
      await _fadeCtrl.reverse();
      setState(() {
        _lineIndex++;
        _charCount = 0;
      });
      _typeCtrl.duration = _typeDuration(_line.text);
      _typeCtrl.reset();
      _typeCtrl.forward();
      _fadeCtrl.forward();
    } else {
      // Fade entire scene out, advance beat, fade back in
      await _sceneCtrl.reverse();
      setState(() {
        _beatIndex++;
        _lineIndex = 0;
        _charCount = 0;
      });
      _typeCtrl.duration = _typeDuration(_line.text);
      _typeCtrl.reset();
      _typeCtrl.forward();
      _sceneCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _line.text.substring(0, _charCount.clamp(0, _line.text.length));

    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Scene (fades between beats)
            FadeTransition(
              opacity: _sceneCtrl,
              child: CustomPaint(
                painter: _ScenePainter(_beat.scene),
                size: Size.infinite,
              ),
            ),

            // Dialogue card (fades between lines)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _sceneCtrl, curve: Curves.easeIn),
                child: FadeTransition(
                  opacity: _fadeCtrl,
                  child: _DialogueCard(
                    speaker: _line.speaker,
                    text: displayText,
                    beatIndex: _beatIndex,
                    totalBeats: _beats.length,
                    isTyping: _isTyping,
                  ),
                ),
              ),
            ),

            // Skip button
            Positioned(
              top: 52,
              right: 20,
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'Skip  â€º',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Dialogue card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DialogueCard extends StatelessWidget {
  final String? speaker;
  final String text;
  final int beatIndex;
  final int totalBeats;
  final bool isTyping;

  const _DialogueCard({
    required this.speaker,
    required this.text,
    required this.beatIndex,
    required this.totalBeats,
    required this.isTyping,
  });

  static const _gold = Color(0xFFD4A017);

  @override
  Widget build(BuildContext context) {
    final isPlayer = speaker == 'Eli';
    final isNarration = speaker == null;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 44),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPlayer
              ? _gold
              : isNarration
                  ? Colors.transparent
                  : Colors.white24,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (speaker != null) ...[
            Text(
              speaker!.toUpperCase(),
              style: TextStyle(
                color: isPlayer ? _gold : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isPlayer ? 24 : 18,
              fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
              height: 1.55,
              fontStyle: isNarration ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (int i = 0; i < totalBeats; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: i == beatIndex ? 22 : 6,
                  height: 4,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: i == beatIndex ? _gold : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const Spacer(),
              if (!isTyping)
                const Text(
                  'tap  â–¶',
                  style: TextStyle(color: Colors.white30, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Scene painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ScenePainter extends CustomPainter {
  final _Scene scene;
  const _ScenePainter(this.scene);

  @override
  void paint(Canvas canvas, Size size) {
    switch (scene) {
      case _Scene.room:
        _paintRoom(canvas, size);
      case _Scene.healer:
        _paintRoom(canvas, size);
        _paintHealerFigure(canvas, size);
      case _Scene.grief:
        _paintRoom(canvas, size);
        _paintGriefFigures(canvas, size);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = const Color(0x44000000),
        );
      case _Scene.rise:
        _paintRiseDawn(canvas, size);
        _paintPlayerFigure(canvas, size);
    }
  }

  // â”€â”€ Room background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _paintRoom(Canvas canvas, Size size) {
    // Night sky gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF04080F), Color(0xFF0A1628)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Moonlit window
    _paintWindow(canvas, size);

    // Candle
    _paintCandle(canvas, Offset(size.width * 0.72, size.height * 0.36), size);

    // Candlelight glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.44, -0.1),
          colors: [const Color(0x35D4861A), Colors.transparent],
          radius: 0.7,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Sick bed
    _paintBed(canvas, size);
  }

  void _paintWindow(Canvas canvas, Size size) {
    final wx = size.width * 0.06;
    final wy = size.height * 0.08;
    const ww = 54.0;
    const wh = 76.0;

    // Moonlight glow outside
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.78, -0.7),
          colors: [const Color(0x20C8D8E8), Colors.transparent],
          radius: 0.5,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Window frame
    canvas.drawRect(
      Rect.fromLTWH(wx, wy, ww, wh),
      Paint()..color = const Color(0xFF1C1206),
    );
    // Pane
    canvas.drawRect(
      Rect.fromLTWH(wx + 4, wy + 4, ww - 8, wh - 8),
      Paint()..color = const Color(0xFF0A1830),
    );
    // Cross bars
    final bar = Paint()
      ..color = const Color(0xFF1C1206)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(wx + ww / 2, wy + 4), Offset(wx + ww / 2, wy + wh - 4), bar);
    canvas.drawLine(Offset(wx + 4, wy + wh / 2), Offset(wx + ww - 4, wy + wh / 2), bar);
    // Moon
    canvas.drawCircle(
      Offset(wx + 16, wy + 20),
      11,
      Paint()..color = const Color(0xFFDDE8D0),
    );
  }

  void _paintCandle(Canvas canvas, Offset pos, Size size) {
    // Body
    canvas.drawRect(
      Rect.fromCenter(center: pos, width: 10, height: 32),
      Paint()..color = const Color(0xFFF0ECD0),
    );
    // Wick
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 16),
      Offset(pos.dx, pos.dy - 22),
      Paint()
        ..color = const Color(0xFF333333)
        ..strokeWidth = 2,
    );
    // Flame
    final flame = Path()
      ..moveTo(pos.dx, pos.dy - 22)
      ..quadraticBezierTo(pos.dx + 7, pos.dy - 33, pos.dx, pos.dy - 44)
      ..quadraticBezierTo(pos.dx - 7, pos.dy - 33, pos.dx, pos.dy - 22);
    canvas.drawPath(flame, Paint()..color = const Color(0xFFFFD060));
    // Flame inner
    final flameInner = Path()
      ..moveTo(pos.dx, pos.dy - 24)
      ..quadraticBezierTo(pos.dx + 3, pos.dy - 30, pos.dx, pos.dy - 38)
      ..quadraticBezierTo(pos.dx - 3, pos.dy - 30, pos.dx, pos.dy - 24);
    canvas.drawPath(flameInner, Paint()..color = const Color(0xFFFFF0A0));
    // Glow
    canvas.drawCircle(
      Offset(pos.dx, pos.dy - 33),
      28,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0x60FFD060), Colors.transparent],
        ).createShader(Rect.fromCenter(
          center: Offset(pos.dx, pos.dy - 33),
          width: 56,
          height: 56,
        )),
    );
  }

  void _paintBed(Canvas canvas, Size size) {
    final bx = size.width * 0.15;
    final by = size.height * 0.48;
    final bw = size.width * 0.65;
    const bh = 90.0;

    // Headboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by - 20, 18, bh + 20),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1A0E06),
    );
    // Footboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + bw - 18, by - 10, 18, bh + 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF1A0E06),
    );
    // Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF120A04),
    );
    // Blanket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx + 4, by + 4, bw - 8, bh - 8),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF0D1F38),
    );
    // Blanket fold
    canvas.drawLine(
      Offset(bx + 4, by + 20),
      Offset(bx + bw - 8, by + 20),
      Paint()
        ..color = const Color(0xFF1A3050)
        ..strokeWidth = 2,
    );
    // Luca's head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bx + 26, by + 14),
        width: 34,
        height: 30,
      ),
      Paint()..color = const Color(0xFFCB8F6A),
    );
    // Fever blush
    canvas.drawCircle(
      Offset(bx + 20, by + 16),
      8,
      Paint()..color = const Color(0x60FF3300),
    );
    canvas.drawCircle(
      Offset(bx + 32, by + 16),
      8,
      Paint()..color = const Color(0x60FF3300),
    );
    // Fever glow
    canvas.drawCircle(
      Offset(bx + 26, by + 14),
      40,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0x30FF4400), Colors.transparent],
        ).createShader(Rect.fromCenter(
          center: Offset(bx + 26, by + 14),
          width: 80,
          height: 80,
        )),
    );
  }

  // â”€â”€ Healer figure â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _paintHealerFigure(Canvas canvas, Size size) {
    // Door glow (right side)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.9, -0.2),
          colors: [const Color(0x30C8A050), Colors.transparent],
          radius: 0.5,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final cx = size.width * 0.8;
    final cy = size.height * 0.22;
    final fig = Paint()..color = const Color(0xFF180C08);

    // Robe
    final robe = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - 26, cy + 140)
      ..lineTo(cx + 26, cy + 140)
      ..close();
    canvas.drawPath(robe, fig);

    // Hood/head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 14), width: 38, height: 42),
      Paint()..color = const Color(0xFF28140A),
    );

    // Face (faint)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 24, height: 26),
      Paint()..color = const Color(0xFFB07850),
    );

    // Staff
    canvas.drawLine(
      Offset(cx + 22, cy - 22),
      Offset(cx + 20, cy + 135),
      Paint()
        ..color = const Color(0xFF5C3D1E)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Staff orb
    canvas.drawCircle(
      Offset(cx + 22, cy - 26),
      7,
      Paint()..color = const Color(0xFFD4A017),
    );

    // Pointing hand
    canvas.drawLine(
      Offset(cx - 2, cy + 30),
      Offset(cx - 38, cy + 50),
      Paint()
        ..color = const Color(0xFF28140A)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    // Hand tip
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 40, cy + 52), width: 14, height: 10),
      Paint()..color = const Color(0xFFB07850),
    );
  }

  // â”€â”€ Grief figures â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _paintGriefFigures(Canvas canvas, Size size) {
    _paintHunchedFigure(canvas, Offset(size.width * 0.33, size.height * 0.3), size);
    _paintHunchedFigure(canvas, Offset(size.width * 0.58, size.height * 0.3), size);
  }

  void _paintHunchedFigure(Canvas canvas, Offset pos, Size size) {
    final fig = Paint()..color = const Color(0xFF180E0A);

    // Hunched body
    final body = Path()
      ..moveTo(pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx - 18, pos.dy + 35, pos.dx - 12, pos.dy + 100)
      ..lineTo(pos.dx + 12, pos.dy + 100)
      ..quadraticBezierTo(pos.dx + 18, pos.dy + 35, pos.dx, pos.dy)
      ..close();
    canvas.drawPath(body, fig);

    // Head (bowed forward)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx - 10, pos.dy - 16), width: 30, height: 32),
      fig,
    );

    // Hands to face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx - 18, pos.dy - 12), width: 16, height: 12),
      Paint()..color = const Color(0xFFCB8F6A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos.dx - 8, pos.dy - 6), width: 14, height: 10),
      Paint()..color = const Color(0xFFCB8F6A),
    );
  }

  // â”€â”€ Dawn / rise â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _paintRiseDawn(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF060810), Color(0xFF10172A)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Pre-dawn horizon glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, 1.4),
          colors: [const Color(0x60D4601A), const Color(0x00000000)],
          radius: 0.8,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Gold aura behind player
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.05),
          colors: [const Color(0x40D4A017), Colors.transparent],
          radius: 0.5,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  void _paintPlayerFigure(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.14;
    final fig = Paint()..color = const Color(0xFF0D1A2A);

    // Body
    final body = Path()
      ..moveTo(cx, cy + 34)
      ..lineTo(cx - 18, cy + 130)
      ..lineTo(cx + 18, cy + 130)
      ..close();
    canvas.drawPath(body, fig);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 14), width: 32, height: 34),
      fig,
    );

    // Arms outstretched â€” determined
    final arm = Paint()
      ..color = const Color(0xFF0D1A2A)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + 52), Offset(cx - 42, cy + 82), arm);
    canvas.drawLine(Offset(cx, cy + 52), Offset(cx + 42, cy + 82), arm);

    // Gold outline
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 14), width: 34, height: 36),
      Paint()
        ..color = const Color(0xFFD4A017)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      Offset(cx, cy + 35),
      Offset(cx, cy + 130),
      Paint()
        ..color = const Color(0xFFD4A017)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.scene != scene;
}


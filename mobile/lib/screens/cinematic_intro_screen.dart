import 'dart:math';
import 'package:flutter/material.dart';

const _wizardLines = [
  'I have done what I can.',
  'If Luca does not eat an orange before dawn...',
  'He will die.',
];

const _sceneImages = [
  'assets/images/lesson1-screen1-option1.jpg',
  'assets/images/lesson1-screen1-option2.jpg',
  'assets/images/lesson1-screen1-option3.jpg',
  'assets/images/lesson1-screen1-option4.jpg',
];

class CinematicIntroScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const CinematicIntroScreen({super.key, required this.onComplete});

  @override
  State<CinematicIntroScreen> createState() => _CinematicIntroState();
}

class _CinematicIntroState extends State<CinematicIntroScreen>
    with TickerProviderStateMixin {
  late final String _image;
  // TTS placeholder — flutter_tts added back when building for Android/iOS
  // ignore: unused_field
  dynamic _tts;

  // Ken Burns: slow zoom over the full scene duration
  late final AnimationController _kbCtrl;
  late final Animation<double> _kbScale;
  late final Animation<Offset> _kbOffset;

  // Fade in the whole scene
  late final AnimationController _fadeCtrl;

  // Speech bubble scale-in
  late final AnimationController _bubbleCtrl;

  // Typewriter
  late final AnimationController _typeCtrl;

  int _lineIndex = 0;
  int _charCount = 0;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();

    _image = _sceneImages[Random().nextInt(_sceneImages.length)];

    // TTS initialised here when flutter_tts is re-added for Android/iOS build

    // Ken Burns — starts focused on right side (wizard), slowly pulls to center
    _kbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..forward();

    _kbScale = Tween<double>(begin: 1.07, end: 1.0).animate(
      CurvedAnimation(parent: _kbCtrl, curve: Curves.easeOut),
    );

    // Start right (wizard face), drift to center
    _kbOffset = Tween<Offset>(
      begin: const Offset(0.07, -0.02),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _kbCtrl, curve: Curves.easeOut));

    // Fade in scene over 1.2s, then trigger speaking
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward().then((_) => _startSpeaking());

    // Bubble bounces in
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Typewriter
    _typeCtrl = AnimationController(vsync: this)
      ..addListener(() {
          if (mounted) {
            setState(() {
              _charCount =
                  (_typeCtrl.value * _wizardLines[_lineIndex].length).floor();
            });
          }
        });
  }

  void _startSpeaking() {
    if (!mounted) return;
    setState(() => _speaking = true);
    _bubbleCtrl.forward();
    _beginTyping();
  }

  void _beginTyping() {
    final line = _wizardLines[_lineIndex];
    _tts?.speak(line);
    _typeCtrl.duration =
        Duration(milliseconds: (line.length * 44).clamp(800, 3000));
    _typeCtrl.reset();
    setState(() => _charCount = 0);
    _typeCtrl.forward();
  }

  void _onTap() {
    if (!_speaking) {
      _fadeCtrl.value = 1.0;
      _startSpeaking();
      return;
    }
    if (_typeCtrl.value < 1.0) {
      _tts?.stop();
      _typeCtrl.stop();
      setState(() => _charCount = _wizardLines[_lineIndex].length);
      return;
    }
    if (_lineIndex < _wizardLines.length - 1) {
      _tts?.stop();
      setState(() => _lineIndex++);
      _beginTyping();
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _tts?.stop();
    _kbCtrl.dispose();
    _fadeCtrl.dispose();
    _bubbleCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _charCount > 0
        ? _wizardLines[_lineIndex].substring(0, _charCount)
        : '';
    final isDone = _charCount >= _wizardLines[_lineIndex].length;
    final isLast = _lineIndex == _wizardLines.length - 1;

    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Scene image with Ken Burns ──────────────────────────────
            FadeTransition(
              opacity: _fadeCtrl,
              child: AnimatedBuilder(
                animation: _kbCtrl,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                    _kbOffset.value.dx * MediaQuery.of(context).size.width,
                    _kbOffset.value.dy * MediaQuery.of(context).size.height,
                  ),
                  child: Transform.scale(
                    scale: _kbScale.value,
                    child: child,
                  ),
                ),
                child: Image.asset(
                  _image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // ── Dark vignette at bottom (readability) ──────────────────
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 280,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
            ),

            // ── Speech bubble ───────────────────────────────────────────
            if (_speaking)
              Positioned(
                top: 28,
                right: 12,
                left: MediaQuery.of(context).size.width * 0.32,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _bubbleCtrl,
                    curve: Curves.elasticOut,
                  ),
                  alignment: Alignment.bottomRight,
                  child: _SpeechBubble(
                    text: displayText,
                    lineIndex: _lineIndex,
                    totalLines: _wizardLines.length,
                  ),
                ),
              ),

            // ── Tap prompt ──────────────────────────────────────────────
            if (_speaking && isDone)
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      isLast ? 'tap to begin  ▶' : 'tap to continue  ▶',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ),
              ),

            // ── Skip ────────────────────────────────────────────────────
            Positioned(
              top: 52,
              left: 20,
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Text(
                    'Skip  ›',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
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

// ─── Speech bubble ─────────────────────────────────────────────────────────────

class _SpeechBubble extends StatelessWidget {
  final String text;
  final int lineIndex;
  final int totalLines;

  const _SpeechBubble({
    required this.text,
    required this.lineIndex,
    required this.totalLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1A1A1A), width: 2.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(2, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'THE HEALER',
                style: TextStyle(
                  color: Color(0xFF3A2060),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(
                  totalLines,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == lineIndex ? 18 : 6,
                    height: 4,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: i == lineIndex
                          ? const Color(0xFF3A2060)
                          : const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Triangle pointer (bottom-right toward healer)
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: CustomPaint(
            size: const Size(22, 14),
            painter: _PointerPainter(),
          ),
        ),
      ],
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF1A1A1A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(_PointerPainter _) => false;
}

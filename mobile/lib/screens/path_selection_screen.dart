import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';

class PathSelectionScreen extends StatelessWidget {
  final List<PathModel> paths;
  final Set<String> triedDeadEnds;
  final void Function(PathModel) onSelect;

  const PathSelectionScreen({
    super.key,
    required this.paths,
    required this.triedDeadEnds,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                children: [
                  Text(
                    'How will you get the orange?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Choose a path. The owl can help if you ask.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: paths.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final path = paths[i];
                  final tried = triedDeadEnds.contains(path.id);
                  return _PathCard(
                    path: path,
                    tried: tried,
                    onTap: tried ? null : () => onSelect(path),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Text('🦉', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'Prof Penny  ·  tap me for a hint',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final PathModel path;
  final bool tried;
  final VoidCallback? onTap;

  const _PathCard({required this.path, required this.tried, this.onTap});

  Color _effortColor(String effort) => switch (effort) {
        'low' => AppTheme.forestGreen,
        'high' => AppTheme.warningOrange,
        _ => AppTheme.skyBlue,
      };

  @override
  Widget build(BuildContext context) {
    final card = path.card;
    final effortColor = _effortColor(card.effort);

    return Opacity(
      opacity: tried ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tried
                  ? Colors.white12
                  : AppTheme.gold.withValues(alpha:0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: effortColor.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: effortColor.withValues(alpha:0.6)),
                    ),
                    child: Text(
                      card.effort.toUpperCase(),
                      style: TextStyle(
                        color: effortColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (tried) ...[
                    const Spacer(),
                    const Text(
                      '✗  Already tried',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                card.label.text,
                style: const TextStyle(
                  color: AppTheme.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('⏱ ', style: TextStyle(fontSize: 13)),
                  Text(
                    card.timeEstimate.text,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const Spacer(),
                  const Text('→ ', style: TextStyle(color: AppTheme.gold, fontSize: 13)),
                  Text(
                    card.visibleReward.text,
                    style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

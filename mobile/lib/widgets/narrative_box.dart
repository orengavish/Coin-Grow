import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NarrativeBox extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const NarrativeBox({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.deepBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withValues(alpha:0.6), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.lightText,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

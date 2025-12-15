import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DecorativeBorder extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double? borderWidth;
  final double borderRadius;
  final bool showBows;

  const DecorativeBorder({
    super.key,
    required this.child,
    this.borderColor,
    this.borderWidth,
    this.borderRadius = 20,
    this.showBows = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppTheme.borderPink;
    final width = borderWidth ?? 2.0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color,
              width: width,
            ),
          ),
          child: child,
        ),
        if (showBows) ...[
          // Top-left bow
          Positioned(
            top: -8,
            left: -8,
            child: _BowDecoration(color: color),
          ),
          // Top-right bow
          Positioned(
            top: -8,
            right: -8,
            child: _BowDecoration(color: color),
          ),
          // Bottom-left bow
          Positioned(
            bottom: -8,
            left: -8,
            child: _BowDecoration(color: color),
          ),
          // Bottom-right bow
          Positioned(
            bottom: -8,
            right: -8,
            child: _BowDecoration(color: color),
          ),
        ],
      ],
    );
  }
}

class _BowDecoration extends StatelessWidget {
  final Color color;

  const _BowDecoration({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.favorite,
        size: 12,
        color: color,
      ),
    );
  }
}





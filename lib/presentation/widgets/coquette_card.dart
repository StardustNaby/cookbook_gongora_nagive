import 'package:flutter/material.dart';
import 'decorative_border.dart';
import '../../core/theme/app_theme.dart';

class CoquetteCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showBows;

  const CoquetteCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.margin,
    this.padding,
    this.onTap,
    this.showBows = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: cardContent,
      );
    }

    return DecorativeBorder(
      showBows: showBows,
      child: cardContent,
    );
  }
}


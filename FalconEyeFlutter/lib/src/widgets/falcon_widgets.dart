import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.bgPrimary,
            Color(0xFF071321),
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: child,
    );
  }
}

class FalconCard extends StatelessWidget {
  const FalconCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.strokePrimary, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x3300D8FF),
            blurRadius: 26,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class FalconPanel extends StatelessWidget {
  const FalconPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeSecondary, width: 2),
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.height = 56,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[AppColors.cyanStart, AppColors.cyanEnd],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.buttonTextDark,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.color = AppColors.textSecondary,
    this.background = AppColors.bgTertiary,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          side: const BorderSide(color: AppColors.strokeSecondary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: color,
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class SelectChipButton extends StatelessWidget {
  const SelectChipButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.cyanEnd : AppColors.bgTertiary;
    final foreground = selected ? AppColors.buttonTextDark : AppColors.textSecondary;
    final border = selected ? AppColors.strokePrimary : AppColors.strokeSecondary;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border, width: 2),
          ),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.cyanSoft,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

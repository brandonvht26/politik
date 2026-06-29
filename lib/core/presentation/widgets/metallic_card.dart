import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MetallicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const MetallicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5), // Ancho del borde dorado
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.metallicGradient,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(0),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
                iconTheme: const IconThemeData(color: AppColors.accent),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppMotion {
  /// The standard curve for page transitions and sliding elements.
  static const Curve standardCurve = Curves.easeOutCubic;

  /// The standard duration for page transitions.
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// The duration for snappy micro-interactions (e.g., button press).
  static const Duration quickDuration = Duration(milliseconds: 150);

  /// Standard PageRouteBuilder for horizontal slide transitions (mimics flipping pages)
  static PageRouteBuilder slidePageRouteBuilder(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: standardDuration,
      reverseTransitionDuration: standardDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: standardCurve));
        final offsetAnimation = animation.drive(tween);
        
        final fadeTween = Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: standardCurve));
        final fadeAnimation = animation.drive(fadeTween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

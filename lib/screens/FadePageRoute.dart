import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  final Duration slideDuration;

  FadePageRoute({
    required this.builder,
    RouteSettings? settings,
    this.slideDuration = const Duration(milliseconds: 1000),
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;

            var slideTween = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero)
                .chain(CurveTween(curve: curve));

            var slideAnimation = slideTween.animate(animation);

            return Stack(
              children: [
                SlideTransition(
                  position: slideAnimation,
                  child: child,
                ),
              ],
            );
          },
          transitionDuration: slideDuration,
        );
}

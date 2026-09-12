import 'package:flutter/material.dart';

const screenTransitionDuration = Duration(milliseconds: 260);

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  SmoothPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: screenTransitionDuration,
        reverseTransitionDuration: screenTransitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.035, 0),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      );
}

/// Transitions a flow's content without replacing its surrounding scaffold.
class AnimatedScreenContent extends StatefulWidget {
  const AnimatedScreenContent({
    super.key,
    required this.step,
    required this.child,
  });
  final int step;
  final Widget child;

  @override
  State<AnimatedScreenContent> createState() => _AnimatedScreenContentState();
}

class _AnimatedScreenContentState extends State<AnimatedScreenContent>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: screenTransitionDuration,
    value: 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void didUpdateWidget(covariant AnimatedScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0.025, 0),
        end: Offset.zero,
      ).animate(_curve),
      child: widget.child,
    ),
  );
}

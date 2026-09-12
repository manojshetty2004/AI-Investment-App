import 'package:flutter/material.dart';

import 'animated_primary_button.dart';

/// Shared tab controls with the same press feedback as other app actions.
class AnimatedAppNavigation extends StatelessWidget {
  const AnimatedAppNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (Icons.home_outlined, 'Home'),
    (Icons.trending_up, 'Market'),
    (Icons.pie_chart_outline, 'Portfolio'),
    (Icons.memory_outlined, 'AI'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Material(
    elevation: 0,
    color: const Color(0xFFF7F9FB),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = currentIndex == index;
            final color = selected
                ? primaryButtonColor
                : const Color(0xFF657B98);
            return Expanded(
              child: Semantics(
                selected: selected,
                child: AnimatedButtonInteraction(
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(16),
                    splashFactory: InkRipple.splashFactory,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_tabs[index].$1, color: color, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[index].$2,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

import 'package:app/widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Primary button animates press and release with one action and haptic',
    (tester) async {
      var taps = 0;
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedPrimaryButton(
                text: 'Continue',
                icon: const Icon(Icons.arrow_forward),
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      );
      final button = find.byType(AnimatedPrimaryButton);
      expect(tester.getSize(button).height, 56);
      expect(
        tester.getSize(button).width,
        tester.getSize(find.byType(Scaffold)).width - 48,
      );
      final scale = find.descendant(
        of: button,
        matching: find.byType(AnimatedScale),
      );
      final opacity = find.descendant(
        of: button,
        matching: find.byType(AnimatedOpacity),
      );
      final container = find.descendant(
        of: button,
        matching: find.byType(AnimatedContainer),
      );
      expect(
        (tester.widget<AnimatedContainer>(container).decoration
                as BoxDecoration)
            .boxShadow,
        isEmpty,
      );
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<AnimatedScale>(scale).scale, 0.95);
      expect(tester.widget<AnimatedScale>(scale).curve, Curves.easeInOut);
      expect(
        tester.widget<AnimatedScale>(scale).duration,
        const Duration(milliseconds: 180),
      );
      expect(tester.widget<AnimatedOpacity>(opacity).opacity, 0.88);
      expect(
        (tester.widget<AnimatedContainer>(container).decoration
                as BoxDecoration)
            .boxShadow,
        isEmpty,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
      expect(tester.widget<AnimatedScale>(scale).scale, 1);
      expect(tester.widget<AnimatedOpacity>(opacity).opacity, 1);
      expect(
        (tester.widget<AnimatedContainer>(container).decoration
                as BoxDecoration)
            .boxShadow,
        isEmpty,
      );
      final canceled = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 200));
      await canceled.cancel();
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(haptics, hasLength(1));
      expect(tester.widget<AnimatedScale>(scale).scale, 1);
    },
  );

  testWidgets(
    'Disabled and loading buttons block activation and respect reduced motion',
    (tester) async {
      var taps = 0;
      Future<void> build({required bool loading, required bool enabled}) =>
          tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: Scaffold(
                body: AnimatedPrimaryButton(
                  text: 'Save',
                  loading: loading,
                  color: Colors.blue,
                  onTap: enabled ? () => taps++ : null,
                ),
              ),
            ),
          );
      await build(loading: true, enabled: true);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AnimatedPrimaryButton));
      await tester.pump();
      expect(taps, 0);
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
        Duration.zero,
      );
      await build(loading: false, enabled: false);
      await tester.tap(find.byType(AnimatedPrimaryButton));
      await tester.pump();
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await build(loading: false, enabled: true);
      await tester.tap(find.byType(AnimatedPrimaryButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
    },
  );

  testWidgets(
    'Compact controls animate and cancel feedback during scroll gestures',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButtonInteraction(
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Details'),
              ),
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Details')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        0.95,
      );
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(taps, 0);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    },
  );
}

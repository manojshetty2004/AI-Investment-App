import 'package:app/screens/app_shell.dart';
import 'package:app/widgets/animated_app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Tab changes keep the navigation bar fixed and preserve investment input',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: AppShell()));
      final bar = find.byType(AnimatedAppNavigation);
      final barElement = tester.element(bar);
      final barRect = tester.getRect(bar);
      Future<void> select(String label) async {
        await tester.tap(find.descendant(of: bar, matching: find.text(label)));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.element(bar), same(barElement));
        expect(tester.getRect(bar), barRect);
        expect(bar, findsOneWidget);
        await tester.pumpAndSettle();
      }

      await select('Market');
      await tester.tap(find.text('Select Low Risk'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '75000');
      await tester.tap(find.text('5 Years'));
      await select('Portfolio');
      await select('Market');
      expect(find.text('Investment Details'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '75000',
      );
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '5 Years'))
            .selected,
        isTrue,
      );
      await select('Home');
      await select('Profile');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('TOTAL PORTFOLIO VALUE'), findsOneWidget);
      expect(tester.getRect(bar), barRect);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Rapid tab selections settle on the latest selection', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    for (final label in ['Portfolio', 'AI', 'Profile', 'Home', 'AI']) {
      await tester.tap(
        find.descendant(
          of: find.byType(AnimatedAppNavigation),
          matching: find.text(label),
        ),
      );
      await tester.pump(const Duration(milliseconds: 40));
    }
    await tester.pumpAndSettle();
    expect(find.text('AI Insights'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedAppNavigation>(find.byType(AnimatedAppNavigation))
          .currentIndex,
      3,
    );
    expect(find.byType(AnimatedAppNavigation), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

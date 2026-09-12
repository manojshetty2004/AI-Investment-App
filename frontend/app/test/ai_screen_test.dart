import 'package:app/screens/app_shell.dart';
import 'package:app/widgets/animated_app_navigation.dart';
import 'package:app/screens/ai_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'AI navigation and demo chat answer questions and preserve conversation',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: AppShell()));
      await tester.tap(find.byTooltip('AI Tips'));
      await tester.pumpAndSettle();
      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.text('Buy HDFC Bank'), findsOneWidget);
      await tester.ensureVisible(find.text('Ask Investment Assistant'));
      await tester.tap(find.text('Ask Investment Assistant'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Send message',
              ),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Show my investments'));
      await tester.pumpAndSettle();
      expect(find.textContaining('₹3,50,000 invested'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'What is the stock price today?',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Live prices and news are not connected'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'What is a SIP?');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(find.textContaining('A mutual fund pools money'), findsOneWidget);
      await tester.tap(find.byTooltip('Close chat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ask Investment Assistant'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('A mutual fund pools money'),
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.textContaining('A mutual fund pools money'), findsOneWidget);
      await tester.tap(find.byTooltip('Close chat'));
      await tester.pumpAndSettle();
      Future<void> tab(String label) async {
        await tester.tap(
          find.descendant(
            of: find.byType(AnimatedAppNavigation),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
      }

      for (final label in ['Portfolio', 'Profile', 'Market']) {
        await tab(label);
        await tab('AI');
        expect(find.byType(AiScreen), findsOneWidget);
      }
      await tab('Home');
      expect(find.byType(HomeScreen), findsOneWidget);
      await tab('AI');
      expect(find.byType(AiScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AI and chat fit narrow screens with enlarged text and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const AiScreen(),
        ),
      );
      await tester.ensureVisible(find.text('Ask Investment Assistant'));
      await tester.tap(find.text('Ask Investment Assistant'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.enterText(find.byType(TextField), 'Explain stocks');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Send message'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('A stock represents ownership'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

import 'package:app/screens/app_shell.dart';
import 'package:app/widgets/animated_app_navigation.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/portfolio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Portfolio opens from Home and supports switching tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.tap(find.byTooltip('Portfolio'));
    await tester.pumpAndSettle();
    expect(find.byType(PortfolioScreen), findsOneWidget);
    expect(find.text('+₹1,35,230 (+38.6%)'), findsOneWidget);
    expect(find.text('Mutual Funds (35%)'), findsOneWidget);
    expect(find.text('Axis Bluechip'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Market'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Your Risk Level'), findsOneWidget);
    await tester.tap(find.text('Select Low Risk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Portfolio'));
    await tester.pumpAndSettle();
    expect(find.byType(PortfolioScreen), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AnimatedAppNavigation),
        matching: find.text('Portfolio'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PortfolioScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Portfolio fits narrow screens with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const PortfolioScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Axis Bluechip'));
    expect(find.text('₹5,000.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

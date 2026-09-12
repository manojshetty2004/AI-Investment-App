import 'package:app/screens/app_shell.dart';
import 'package:app/widgets/animated_app_navigation.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile navigation, account details and logout work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    Future<void> tab(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(AnimatedAppNavigation),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    await tab('Profile');
    expect(find.text('Alex Sharma'), findsOneWidget);
    expect(find.text('alex.sharma@terminal.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Personal Information'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Account editing is not connected yet.'),
      findsOneWidget,
    );
    Navigator.of(
      tester.element(
        find.textContaining('Account editing is not connected yet.'),
      ),
    ).pop();
    await tester.pumpAndSettle();
    await tab('Portfolio');
    await tab('Profile');
    expect(find.byType(ProfileScreen), findsOneWidget);
    await tab('Market');
    await tester.tap(find.text('Select Low Risk'));
    await tester.pumpAndSettle();
    await tab('Profile');
    expect(find.byType(ProfileScreen), findsOneWidget);
    await tab('Home');
    expect(find.byType(HomeScreen), findsOneWidget);
    await tab('Profile');
    await tester.tap(find.text('Logout Account'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
      isFalse,
    );
    expect(find.byType(HomeScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile fits a narrow screen with enlarged text', (
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
        home: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Logout Account'));
    expect(tester.takeException(), isNull);
  });
}

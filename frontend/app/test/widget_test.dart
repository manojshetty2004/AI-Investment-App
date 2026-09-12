import 'package:app/screens/app_shell.dart';
import 'package:app/main.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash opens login after five seconds', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(LoginScreen), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login fits mobile and supports form controls', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
    await tester.tap(find.text('Remember me'));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tap(find.text('Login Securely'));
    await tester.pump();
    expect(find.text('Enter your email or username'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    tester.view.physicalSize = const Size(320, 568);
    await tester.pump();
  });
  testWidgets('Login preview opens home and recommendations', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).last, 'admin');
    await tester.tap(find.text('Login Securely'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('₹4,85,230'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();
    expect(find.text('Sovereign Gold Bond'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home fits a narrow screen and enlarged text', (tester) async {
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
        home: const AppShell(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('Incorrect admin credentials do not open home', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    for (final credentials in [
      ['admin', 'wrong'],
      ['wrong', 'admin'],
    ]) {
      await tester.enterText(find.byType(TextFormField).first, credentials[0]);
      await tester.enterText(find.byType(TextFormField).last, credentials[1]);
      await tester.ensureVisible(find.text('Login Securely'));
      await tester.tap(find.text('Login Securely'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Invalid credentials'), findsOneWidget);
    }
  });
}

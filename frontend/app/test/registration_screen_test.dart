import 'package:app/screens/home_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> enterCode(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const ValueKey('registration-phone')),
    '9876543210',
  );
  await tapText(tester, 'Get OTP');
  for (var i = 0; i < 6; i++) {
    await tester.enterText(find.byKey(ValueKey('otp-$i')), '${i + 1}');
  }
  await tapText(tester, 'Verify & Register');
}

void main() {
  testWidgets(
    'Registration starts unselected, preserves choices and never signs in',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tapText(tester, 'Register');
      expect(find.byType(RegistrationScreen), findsOneWidget);
      await tapText(tester, 'Verify & Register');
      expect(find.text('Enter a 10-digit phone number'), findsOneWidget);
      await enterCode(tester);
      expect(find.text('Setup Investor Profile'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('FULL NAME')))
            .controller!
            .text,
        isEmpty,
      );
      expect(
        tester
            .widgetList<ChoiceChip>(find.byType(ChoiceChip))
            .every((chip) => !chip.selected),
        isTrue,
      );
      expect(find.text('Select monthly income'), findsWidgets);
      await tapText(tester, 'Continue');
      expect(find.text('Setup Investor Profile'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('FULL NAME')),
        'Sam Test',
      );
      await tester.enterText(find.byKey(const ValueKey('AGE')), '28');
      await tester.enterText(
        find.byKey(const ValueKey('OCCUPATION')),
        'Engineer',
      );
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('₹50,000 – ₹1,00,000').last);
      await tester.pumpAndSettle();
      await tapText(tester, 'Beginner');
      await tapText(tester, 'Advanced');
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Beginner'))
            .selected,
        isFalse,
      );
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Advanced'))
            .selected,
        isTrue,
      );
      await tapText(tester, 'Retirement');
      await tapText(tester, 'Continue');
      expect(find.text('Risk Suitability Analysis'), findsOneWidget);
      await tapText(tester, 'Sign Up');
      expect(find.text('Select an answer to continue.'), findsOneWidget);
      await tapText(
        tester,
        'Do nothing and wait for the market to eventually recover.',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Advanced'))
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Retirement'))
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('FULL NAME')))
            .controller!
            .text,
        'Sam Test',
      );
      await tapText(tester, 'Continue');
      await tapText(tester, 'Sign Up');
      expect(find.text('Preview complete'), findsOneWidget);
      expect(find.text('Retirement'), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      await tapText(tester, 'Back to Login');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(RegistrationScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Registration fits narrow screens and resets OTP after phone edits',
    (tester) async {
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
          home: const RegistrationScreen(),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('registration-phone')),
        '9876543210',
      );
      await tapText(tester, 'Get OTP');
      await tester.enterText(find.byKey(const ValueKey('otp-0')), '1');
      await tester.enterText(
        find.byKey(const ValueKey('registration-phone')),
        '9876543211',
      );
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byKey(const ValueKey('otp-0'))).enabled,
        isFalse,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('otp-0')))
            .controller!
            .text,
        isEmpty,
      );
      await enterCode(tester);
      expect(find.text('Setup Investor Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Continue'));
      expect(tester.takeException(), isNull);
    },
  );
}

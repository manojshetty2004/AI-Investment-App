import 'package:app/screens/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

ApiService _mockApi() => ApiService(client: MockClient((request) async {
  final input = jsonDecode(request.body) as Map<String, dynamic>;
  final low = input['risk_type'] == 'Low';
  final portfolio = low
      ? [
          {'instrument': 'Index Mutual Fund', 'allocation_percentage': 60, 'allocation_amount': 60000},
          {'instrument': 'Nifty ETF', 'allocation_percentage': 25, 'allocation_amount': 25000},
          {'instrument': 'Debt Fund', 'allocation_percentage': 15, 'allocation_amount': 15000},
        ]
      : [
          {'stock': 'TCS', 'allocation_percentage': 50, 'allocation_amount': 50000},
          {'stock': 'INFY', 'allocation_percentage': 50, 'allocation_amount': 50000},
        ];
  return http.Response(jsonEncode({
    'risk_analysis': {'strategy': low ? 'Conservative' : 'Growth', 'risk_summary': 'Risk analysis complete.'},
    'research_results': low ? null : {'recommended_stocks': ['TCS', 'INFY'], 'market_sentiment': 'Bullish'},
    'portfolio_allocation': portfolio,
    'expected_return': low ? '8-10%' : '12-18%',
    'final_recommendation': 'Portfolio generated.',
  }), 200);
}));

void main() {
  for (final low in [true, false]) {
    testWidgets(
      '${low ? 'Low' : 'Medium / high'} risk completes the investment preview',
      (tester) async {
        tester.view.physicalSize = const Size(402, 874);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(home: AppShell(apiService: _mockApi())));
        await tester.tap(find.byTooltip('Invest'));
        await tester.pumpAndSettle();
        final selection = find.text(
          low ? 'Select Low Risk' : 'Select Medium / High Risk',
        );
        await tester.ensureVisible(selection);
        await tester.tap(selection);
        await tester.pumpAndSettle();
        expect(find.text('Investment Details'), findsOneWidget);
        expect(
          find.text(low ? 'Low Risk Strategy' : 'Medium / High Risk Strategy'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextFormField), '499');
        await tester.tap(find.text('Generate Plan'));
        await tester.pump();
        expect(
          find.text('Enter an investment amount of at least ₹500'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextFormField), '100000');
        await tester.tap(find.text('3 Years'));
        await tester.tap(find.text('Generate Plan'));
        await tester.pumpAndSettle();
        expect(find.text('AI Recommendation'), findsOneWidget);
        expect(find.text('₹1,00,000'), findsOneWidget);
        expect(find.text('3 Years'), findsOneWidget);
        expect(
          find.text(low ? 'Index Mutual Fund' : 'TCS'),
          findsOneWidget,
        );
        expect(find.text(low ? '₹60,000' : '₹50,000'), low ? findsOneWidget : findsNWidgets(2));
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Invest Now'));
        await tester.tap(find.text('Invest Now'));
        await tester.pumpAndSettle();
        expect(find.text('Investment preview'), findsOneWidget);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Back'));
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField))
              .controller!
              .text,
          '100000',
        );
        expect(
          tester
              .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '3 Years'))
              .selected,
          isTrue,
        );
        await tester.tap(find.text('Home').last);
        await tester.pumpAndSettle();
        expect(find.text('TOTAL PORTFOLIO VALUE'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Investment pages fit narrow screens with enlarged text and support back',
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
          home: AppShell(apiService: _mockApi()),
        ),
      );
      await tester.ensureVisible(find.byTooltip('Invest'));
      await tester.tap(find.byTooltip('Invest'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Select Medium / High Risk'));
      await tester.tap(find.text('Select Medium / High Risk'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Generate Plan'));
      await tester.tap(find.text('Generate Plan'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Invest Now'));
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Investment Details'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Choose Your Risk Level'), findsOneWidget);
    },
  );
}

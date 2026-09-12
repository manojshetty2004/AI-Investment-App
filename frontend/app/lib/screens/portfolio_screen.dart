import 'dart:math' as math;

import 'package:flutter/material.dart';

const _background = Color(0xFFF7F9FB);
const _surface = Color(0xFFF1F5F9);
const _border = Color(0xFFE5E7EB);
const _ink = Color(0xFF131C30);
const _muted = Color(0xFF657B98);
const _green = Color(0xFF00C853);

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  Widget _text(
    String text, {
    double size = 13,
    Color color = _ink,
    bool bold = false,
  }) => Text(
    text,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    ),
  );

  Widget _panel(Widget child, {double padding = 18}) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: _surface,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [],
    ),
    child: child,
  );

  Widget _value(String label, String amount, {bool right = false}) => Column(
    crossAxisAlignment: right
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      _text(label, size: 10, color: const Color(0xFF485B77)),
      const SizedBox(height: 6),
      _text(amount, size: 20, bold: true),
    ],
  );

  Widget _summary() => _panel(
    Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 20,
            runSpacing: 16,
            children: [
              _value('INVESTED VALUE', '₹3,50,000'),
              _value('CURRENT VALUE', '₹4,85,230', right: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              _text(
                'Total Unrealized Profit',
                size: 12,
                color: const Color(0xFF485B77),
              ),
              _text('+₹1,35,230 (+38.6%)', size: 14, color: _green, bold: true),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _allocation() => _panel(
    Row(
      children: [
        Semantics(
          label: 'Asset allocation: Stocks 45%, Mutual Funds 35%, F&O 20%',
          image: true,
          child: const SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(painter: _PortfolioChart()),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in [
                (const Color(0xFF1BC45B), 'Stocks (45%)'),
                (const Color(0xFF2563EB), 'Mutual Funds (35%)'),
                (const Color(0xFFED2028), 'F&O (20%)'),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: item.$1, size: 8),
                      const SizedBox(width: 8),
                      Expanded(child: _text(item.$2, size: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
    padding: 15,
  );

  Widget _transaction(
    String type,
    String title,
    String details,
    String amount,
  ) {
    final sell = type == 'SELL';
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: sell ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: _text(
        type,
        size: 10,
        color: sell ? const Color(0xFFFF2525) : const Color(0xFF00AF45),
        bold: true,
      ),
    );
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _text(title, bold: true),
        const SizedBox(height: 4),
        _text(details, size: 11, color: _muted),
      ],
    );
    return _panel(
      LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(13) > 16;
          return Row(
            children: [
              badge,
              const SizedBox(width: 12),
              Expanded(
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          info,
                          const SizedBox(height: 8),
                          _text(amount, bold: true),
                        ],
                      )
                    : info,
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                _text(amount, bold: true),
              ],
            ],
          );
        },
      ),
      padding: 12,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _text('Portfolio', size: 21, bold: true),
                const SizedBox(height: 4),
                _text(
                  'Asset Allocation & Performance Insights',
                  size: 12,
                  color: const Color(0xFF485B77),
                ),
                const SizedBox(height: 20),
                _summary(),
                const SizedBox(height: 22),
                _text(
                  'ASSET ALLOCATION',
                  size: 13,
                  color: const Color(0xFF485B77),
                  bold: true,
                ),
                const SizedBox(height: 12),
                _allocation(),
                const SizedBox(height: 22),
                _text(
                  'RECENT TRANSACTIONS',
                  size: 13,
                  color: const Color(0xFF485B77),
                  bold: true,
                ),
                const SizedBox(height: 12),
                _transaction(
                  'BUY',
                  'RELIANCE',
                  '10 shares @ ₹2,450 · 22 Nov 2023',
                  '₹24,500.00',
                ),
                const SizedBox(height: 12),
                _transaction(
                  'SELL',
                  'TCS',
                  '5 shares @ ₹3,520 · 21 Nov 2023',
                  '₹17,600.00',
                ),
                const SizedBox(height: 12),
                _transaction(
                  'SIP',
                  'Axis Bluechip',
                  'Mutual Fund Monthly · 15 Nov 2023',
                  '₹5,000.00',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _PortfolioChart extends CustomPainter {
  const _PortfolioChart();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(6);
    var start = -math.pi / 2;
    for (final segment in [
      (0.45, const Color(0xFF1BC45B)),
      (0.35, const Color(0xFF2563EB)),
      (0.20, const Color(0xFFED2028)),
    ]) {
      final sweep = math.pi * 2 * segment.$1;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = segment.$2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PortfolioChart oldDelegate) => false;
}

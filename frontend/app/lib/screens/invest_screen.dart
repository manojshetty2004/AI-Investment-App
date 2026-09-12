import '../widgets/screen_transition.dart';
import '../widgets/animated_primary_button.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

const _background = Color(0xFFF7F9FB);
const _ink = Color(0xFF131C30);
const _muted = Color(0xFF657B98);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF1BC45B);
const _colors = [
  _green,
  Color(0xFF3B82F6),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
];

String _money(num value) {
  final digits = value.round().toString();
  if (digits.length <= 3) return '₹$digits';
  final head = digits.substring(0, digits.length - 3);
  final groups = head.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{2})+$)'),
    (m) => '${m[1]},',
  );
  return '₹$groups,${digits.substring(digits.length - 3)}';
}

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<InvestScreen> createState() => InvestScreenState();
}

class InvestScreenState extends State<InvestScreen> {
  late final _api = widget.apiService ?? ApiService();
  final _amount = TextEditingController(text: '50,000');
  final _form = GlobalKey<FormState>();
  int _step = 0;
  bool _lowRisk = true;
  int _tenure = 1;
  Map<String, dynamic>? _recommendationData;
  bool _loading = false;
  static const _tenures = [
    '6 Months',
    '1 Year',
    '3 Years',
    '5 Years',
    '10 Years',
  ];
  static const _years = [0.5, 1.0, 3.0, 5.0, 10.0];
  String get _risk => _lowRisk ? 'Low Risk' : 'Medium / High Risk';
  double get _value => double.tryParse(_amount.text.replaceAll(',', '')) ?? 0;

  bool handleBack() {
    if (_step == 0) return false;
    setState(() => _step--);
    return true;
  }

  @override
  void dispose() {
    if (widget.apiService == null) _api.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (_loading || !_form.currentState!.validate()) return;
    if (_tenure == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a tenure of at least 1 year.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final data = await _api.getRecommendation(
        riskType: _lowRisk ? 'Low' : 'MediumHigh',
        investmentAmount: _value,
        investmentTenure: _years[_tenure].toInt(),
      );
      if (!mounted) return;
      setState(() {
        _recommendationData = data;
        _step = 2;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _text(
    String text, {
    double size = 14,
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

  Widget _button(String title, VoidCallback onPressed, {bool primary = true}) =>
      AnimatedPrimaryButton(
        text: title,
        onTap: onPressed,
        foregroundColor: primary ? primaryButtonColor : _ink,
      );

  Widget _panel(
    Widget child, {
    Color color = Colors.white,
    double padding = 18,
  }) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: _border),
      boxShadow: const [],
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _riskCard(bool low) {
    final selected = _lowRisk == low;
    final accent = low ? _green : const Color(0xFFF59E0B);
    final points = low
        ? [
            ('Mutual Funds', 'Top conservative & hybrid funds'),
            ('Stable Returns', 'Predictable wealth growth over time'),
            ('Lower Risk', 'Capital preservation is prioritized'),
          ]
        : [
            ('Stocks & Equities', 'Direct trading in shares'),
            ('Futures & Options', 'Leveraged trading instruments'),
            ('Higher Return', 'Aggressive potential portfolio yield'),
          ];
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _text(
                      low ? 'Low Risk' : 'Medium / High Risk',
                      size: 18,
                      bold: true,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: low
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: _text(
                        low ? 'SAFE' : 'ALPHA',
                        size: 10,
                        color: accent,
                        bold: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: low
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                child: Icon(
                  low ? Icons.verified_user_outlined : Icons.trending_up,
                  color: accent,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 9),
                    child: Icon(Icons.circle, size: 6, color: accent),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: point.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          TextSpan(text: ' - ${point.$2}'),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Color(0xFF485B77),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          _button(
            low ? 'Select Low Risk' : 'Select Medium / High Risk',
            () => setState(() {
              _lowRisk = low;
              _step = 1;
            }),
            primary: selected,
          ),
        ],
      ),
      color: selected ? const Color(0xFFF0FDF4) : Colors.white,
    );
  }

  Widget _selection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _text('Invest', size: 25, bold: true),
      const SizedBox(height: 6),
      _text('Choose Your Risk Level', color: const Color(0xFF485B77)),
      const SizedBox(height: 26),
      _riskCard(true),
      const SizedBox(height: 16),
      _riskCard(false),
    ],
  );

  Widget _details() => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _text('Risk Strategy:', color: const Color(0xFF485B77)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                border: Border.all(color: _green),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _text(
                '$_risk Strategy',
                size: 12,
                color: const Color(0xFF00A83E),
                bold: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _text('Investment Amount', bold: true),
        const SizedBox(height: 10),
        TextFormField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
            LengthLimitingTextInputFormatter(12),
          ],
          style: const TextStyle(fontSize: 18, color: _ink),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.currency_rupee, color: _ink, size: 21),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _green),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          validator: (_) => _value < 500
              ? 'Enter an investment amount of at least ₹500'
              : null,
        ),
        const SizedBox(height: 10),
        _text(
          'Minimum initial investment amount is ₹500',
          size: 12,
          color: _muted,
        ),
        const SizedBox(height: 28),
        _text('Investment Tenure', bold: true),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _tenures.length,
            (index) => AnimatedButtonInteraction(
              child: ChoiceChip(
                elevation: 0,
                pressElevation: 0,
                label: Text(_tenures[index]),
                selected: _tenure == index,
                showCheckmark: false,
                onSelected: (_) => setState(() => _tenure = index),
                selectedColor: Colors.white,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: _tenure == index ? primaryButtonColor : _ink,
                  fontWeight: _tenure == index
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _button(_loading ? 'Generating Plan...' : 'Generate Plan', _generatePlan),
      ],
    ),
  );

  Widget _summaryItem(String label, String value, {Color color = _ink}) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _text(label, size: 10, color: _muted),
            const SizedBox(height: 4),
            _text(value, size: 13, color: color, bold: true),
          ],
        ),
      );

  Widget _recommendation() {
    final data = _recommendationData!;
    final risk = data['risk_analysis'] as Map<String, dynamic>;
    final research = data['research_results'] as Map<String, dynamic>?;
    final positions = (data['portfolio_allocation'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final names = positions.map((item) => (item['instrument'] ?? item['stock']).toString()).toList();
    final weights = positions.map((item) => (item['allocation_percentage'] as num).toInt()).toList();
    final expectedReturn = data['expected_return'].toString();
    final finalRecommendation = data['final_recommendation'].toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryItem('RISK LEVEL', _risk, color: const Color(0xFF00A83E)),
              const SizedBox(width: 12),
              _summaryItem('AMOUNT', _money(_value)),
              const SizedBox(width: 12),
              _summaryItem('TENURE', _tenures[_tenure]),
            ],
          ),
          color: const Color(0xFFF1F5F9),
          padding: 15,
        ),
        const SizedBox(height: 26),
        _text('AI-GENERATED PORTFOLIO', color: _muted, bold: true),
        const SizedBox(height: 16),
        _panel(
          Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final chart = SizedBox(
                    width: 130,
                    height: 130,
                    child: CustomPaint(
                      painter: _AllocationPainter(weights),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _text(
                              'AI MODEL',
                              size: 10,
                              color: _muted,
                              bold: true,
                            ),
                            const SizedBox(height: 4),
                            _text(
                              risk['strategy'].toString(),
                              size: 16,
                              color: const Color(0xFF00A83E),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  final description = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _text(
                        _lowRisk ? 'Risk Analysis' : 'Research Results',
                        bold: true,
                      ),
                      const SizedBox(height: 8),
                      _text(
                        research == null
                            ? risk['risk_summary'].toString()
                            : '${risk['risk_summary']}\n${research['summary'] ?? ''}\nMarket sentiment: ${research['market_sentiment'] ?? 'Not assessed'}\n${(research['recommended_stocks'] as List<dynamic>).join(', ')}',
                        size: 12,
                        color: const Color(0xFF485B77),
                      ),
                    ],
                  );
                  return constraints.maxWidth < 290
                      ? Column(
                          children: [
                            chart,
                            const SizedBox(height: 16),
                            description,
                          ],
                        )
                      : Row(
                          children: [
                            chart,
                            const SizedBox(width: 20),
                            Expanded(child: description),
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < names.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == names.length - 1 ? 0 : 14,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 10, color: _colors[i % _colors.length]),
                      const SizedBox(width: 10),
                      Expanded(child: _text(names[i], size: 12)),
                      const SizedBox(width: 8),
                      _text('${weights[i]}%', size: 12, bold: true),
                      const SizedBox(width: 10),
                      _text(
                        _money(positions[i]['allocation_amount'] as num),
                        size: 11,
                        color: _muted,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          padding: 15,
        ),
        const SizedBox(height: 24),
        _panel(
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _text(
                    'FINAL RECOMMENDATION',
                    size: 11,
                    color: const Color(0xFF00A83E),
                  ),
                  const SizedBox(height: 5),
                  _text(finalRecommendation, size: 13, bold: true),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _text(
                    'EXP. RETURN',
                    size: 11,
                    color: const Color(0xFF00A83E),
                  ),
                  const SizedBox(height: 5),
                  _text(
                    '$expectedReturn illustrative p.a.',
                    size: 13,
                    color: const Color(0xFF00A83E),
                    bold: true,
                  ),
                ],
              ),
            ],
          ),
          color: const Color(0xFFDCFCE7),
          padding: 15,
        ),
        const SizedBox(height: 12),
        _text(
          'Agent-generated allocation. Expected returns are illustrative, not guaranteed.',
          size: 11,
          color: _muted,
        ),
        const SizedBox(height: 20),
        _button(
          'Invest Now',
          () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              elevation: 0,
              title: const Text('Investment preview'),
              content: Text(
                '${_money(_value)} • $_risk • ${_tenures[_tenure]}\n\nInvestment execution is not connected yet. No money has been invested.',
              ),
              actions: [
                AnimatedButtonInteraction(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
          child: AnimatedScreenContent(
            step: _step,
            child: SingleChildScrollView(
              key: ValueKey(_step),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_step > 0) ...[
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(color: _border),
                          ),
                          child: AnimatedButtonInteraction(
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => setState(() => _step--),
                              icon: const Icon(Icons.chevron_left, color: _ink),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _text(
                            _step == 1
                                ? 'Investment Details'
                                : 'AI Recommendation',
                            size: 18,
                            bold: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                  if (_step == 0)
                    _selection()
                  else if (_step == 1)
                    _details()
                  else
                    _recommendation(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AllocationPainter extends CustomPainter {
  const _AllocationPainter(this.weights);
  final List<int> weights;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    var start = -math.pi / 2;
    for (var i = 0; i < weights.length; i++) {
      final sweep = 2 * math.pi * weights[i] / 100;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = _colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _AllocationPainter oldDelegate) =>
      oldDelegate.weights != weights;
}

import '../widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onNavigate});

  final ValueChanged<int>? onNavigate;

  static const _background = Color(0xFFF7F9FB);
  static const _surface = Color(0xFFF1F5F9);
  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF131C30);
  static const _muted = Color(0xFF657B98);
  static const _green = Color(0xFF00C853);

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  BoxDecoration _panel(double radius) => BoxDecoration(
    color: _surface,
    border: Border.all(color: _border),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [],
  );

  BoxDecoration _actionPanel() => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: _border),
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [],
  );

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFDCFCE7),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF00A83E),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _investment(
    BuildContext context, {
    required String title,
    required String provider,
    required String returns,
    bool aiChoice = false,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(15),
      decoration: _panel(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (aiChoice) _badge('AI CHOICE'),
              const Text(
                'Low Risk',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(provider, style: const TextStyle(fontSize: 12, color: _muted)),
          const SizedBox(height: 8),
          const Divider(color: _border, height: 12),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Exp. Returns',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
              ),
              Text(
                returns,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00AD49),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRecommendations(BuildContext context) {
    showModalBottomSheet<void>(
      elevation: 0,
      context: context,
      backgroundColor: _background,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 20),
              _investment(
                context,
                title: 'Nifty 50 Index Fund',
                provider: 'UTI Mutual Fund',
                returns: '12.8%',
                aiChoice: true,
              ),
              const SizedBox(height: 12),
              _investment(
                context,
                title: 'Sovereign Gold Bond',
                provider: 'RBI Govt',
                returns: '—',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String label, {
    bool green = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: _actionPanel(),
            child: AnimatedButtonInteraction(
              child: IconButton(
                tooltip: label,
                onPressed: () {
                  final tab = {
                    'Invest': 1,
                    'Portfolio': 2,
                    'AI Tips': 3,
                  }[label];
                  if (tab != null) {
                    onNavigate?.call(tab);
                  } else {
                    _comingSoon(context, label);
                  }
                },
                icon: Icon(icon, color: green ? _green : _ink, size: 25),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE1E9EF),
                        child: Text(
                          'AY',
                          style: TextStyle(
                            fontSize: 14,
                            color: _ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning,',
                              style: TextStyle(fontSize: 12, color: _muted),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Alex Young',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: _actionPanel(),
                        child: AnimatedButtonInteraction(
                          child: IconButton(
                            tooltip: 'Notifications',
                            padding: EdgeInsets.zero,
                            onPressed: () => showModalBottomSheet<void>(
                              elevation: 0,
                              context: context,
                              showDragHandle: true,
                              builder: (_) => const SafeArea(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      'You’re all caught up. No new notifications.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            icon: const Badge(
                              smallSize: 5,
                              backgroundColor: _green,
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 24,
                                color: _ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(19),
                    decoration: _panel(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL PORTFOLIO VALUE',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF485B77),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹4,85,230',
                                style: TextStyle(
                                  fontSize: 34,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w800,
                                  color: _ink,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'INR',
                                style: TextStyle(fontSize: 12, color: _muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Wrap(
                          spacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.trending_up, color: _green, size: 16),
                            Text(
                              '+₹11,400 (+2.4%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _green,
                              ),
                            ),
                            Text(
                              "Today's P&L",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF899BB4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: _border),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MARKET SENTIMENT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _muted,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: _green,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Bullish',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'RISK ASSESSMENT',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _muted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _badge('Low Risk'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _action(context, Icons.north_east, 'Invest', green: true),
                      _action(context, Icons.monitor_heart_outlined, 'Trade'),
                      _action(context, Icons.pie_chart_outline, 'Portfolio'),
                      _action(
                        context,
                        Icons.bolt_outlined,
                        'AI Tips',
                        green: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended For You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                      AnimatedButtonInteraction(
                        child: TextButton(
                          onPressed: () => _showRecommendations(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF00AD49),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(58, 40),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _investment(
                          context,
                          title: 'Nifty 50 Index Fund',
                          provider: 'UTI Mutual Fund',
                          returns: '12.8%',
                          aiChoice: true,
                        ),
                        const SizedBox(width: 12),
                        _investment(
                          context,
                          title: 'Sovereign Gold Bond',
                          provider: 'RBI Govt',
                          returns: '—',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

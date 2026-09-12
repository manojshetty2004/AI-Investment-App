import '../widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';

const _background = Color(0xFFF7F9FB);
const _surface = Color(0xFFF1F5F9);
const _border = Color(0xFFE5E7EB);
const _ink = Color(0xFF131C30);
const _muted = Color(0xFF657B98);
const _green = Color(0xFF1BC45B);

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _messages = <({bool user, String text})>[
    (
      user: false,
      text:
          'Hi! Ask about stocks, investment concepts, or the sample portfolio shown in this app. This demo uses prepared replies, with no live prices or access to your accounts.',
    ),
  ];

  void _openChat() => showModalBottomSheet<void>(
    elevation: 0,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: _background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _InvestmentChat(messages: _messages),
  );

  Widget _text(
    String value, {
    double size = 13,
    Color color = _ink,
    bool bold = false,
  }) => Text(
    value,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    ),
  );

  Widget _panel(Widget child) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: _surface,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _allocation(String label, List<int> parts) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _text(label, size: 10, color: _muted),
      const SizedBox(height: 7),
      Semantics(
        label:
            '$label: Stocks ${parts[0]}%, Mutual Funds ${parts[1]}%, F&O ${parts[2]}%',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                for (var i = 0; i < parts.length; i++)
                  Expanded(
                    flex: parts[i],
                    child: ColoredBox(
                      color: [
                        _green,
                        const Color(0xFF2563EB),
                        const Color(0xFFED2028),
                      ][i],
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

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
                _text('AI Insights', size: 21, bold: true),
                const SizedBox(height: 4),
                _text(
                  'Personalized Quantum Intelligence Picks',
                  size: 12,
                  color: const Color(0xFF485B77),
                ),
                const SizedBox(height: 22),
                _text(
                  'HIGH CONVICTION PICKS',
                  size: 13,
                  color: const Color(0xFF485B77),
                  bold: true,
                ),
                const SizedBox(height: 12),
                _panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _text('Buy HDFC Bank', size: 16, bold: true),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _text(
                              'SAMPLE',
                              size: 9,
                              color: const Color(0xFF2563EB),
                              bold: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: _background,
                          border: Border.all(color: _border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _text(
                              'AI THESIS',
                              size: 10,
                              color: const Color(0xFF00AD49),
                              bold: true,
                            ),
                            const SizedBox(height: 5),
                            _text(
                              'Credit expansion outperforming benchmarks. Oversold technical markers signal 15% medium-term upside swing.',
                              size: 12,
                              color: const Color(0xFF485B77),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _text('Target Return', size: 10, color: _muted),
                                const SizedBox(height: 4),
                                _text(
                                  '15.4%',
                                  size: 16,
                                  color: const Color(0xFF00AD49),
                                  bold: true,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _text(
                                  'Est. Timeframe',
                                  size: 10,
                                  color: _muted,
                                ),
                                const SizedBox(height: 4),
                                _text('30 Days', bold: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: _border),
                      const SizedBox(height: 10),
                      _text(
                        'HDFC merger synergy unlocks efficiency, driving margin projection beats this quarter.',
                        size: 11,
                        color: _muted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _text('Portfolio Rebalancing', size: 14, bold: true),
                      const SizedBox(height: 6),
                      _text(
                        'Shift 10% from volatile Equities to Mutual Funds to insulate current profits.',
                        size: 12,
                        color: const Color(0xFF485B77),
                      ),
                      const SizedBox(height: 18),
                      _allocation('CURRENT ALLOCATION', [63, 31, 6]),
                      const SizedBox(height: 14),
                      _allocation('SUGGESTED REBALANCE', [53, 41, 6]),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          for (final item in [
                            (_green, 'Stocks'),
                            (const Color(0xFF2563EB), 'Mutual Funds'),
                            (const Color(0xFFED2028), 'F&O'),
                          ])
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 6, color: item.$1),
                                const SizedBox(width: 5),
                                _text(item.$2, size: 10, color: _muted),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _text(
                  'Illustrative insights from the design preview. No live market analysis or account changes.',
                  size: 11,
                  color: _muted,
                ),
                const SizedBox(height: 20),
                AnimatedPrimaryButton(
                  onTap: _openChat,
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  text: 'Ask Investment Assistant',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _InvestmentChat extends StatefulWidget {
  const _InvestmentChat({required this.messages});
  final List<({bool user, String text})> messages;

  @override
  State<_InvestmentChat> createState() => _InvestmentChatState();
}

class _InvestmentChatState extends State<_InvestmentChat> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _reply(String question) {
    final text = question.toLowerCase();
    if (RegExp(r'\b(price|today|latest|live|news|quote)\b').hasMatch(text)) {
      return 'Live prices and news are not connected in this demo. I can explain stock concepts or summarize the sample portfolio displayed in the app.';
    }
    if (RegExp(
      r'\b(my|portfolio|invested|holdings|transactions|done)\b',
    ).hasMatch(text)) {
      return 'The sample Portfolio screen shows ₹3,50,000 invested, ₹4,85,230 current value, and ₹1,35,230 unrealized profit (+38.6%). Its allocation is Stocks 45%, Mutual Funds 35%, and F&O 20%. The listed transactions are RELIANCE (buy), TCS (sell), and Axis Bluechip (SIP). These are demo figures, not your connected investments; no trades have been executed by this app.';
    }
    if (text.contains('hdfc') ||
        RegExp(r'\b(buy|sell|pick|recommend)\b').hasMatch(text)) {
      return 'The HDFC Bank card is a static design example, including its 15.4% target and 30-day timeframe. It is not a current forecast or personalized buy recommendation. Live research and suitability analysis are not connected yet.';
    }
    if (RegExp(r'\b(sip|mutual|funds|fund)\b').hasMatch(text)) {
      return 'A mutual fund pools money into a portfolio managed under a stated strategy. A SIP is a way to invest a fixed amount at regular intervals. Both the fund’s holdings and fees matter, and values can rise or fall. The Axis Bluechip SIP shown in this app is a sample transaction.';
    }
    if (RegExp(
      r'\b(rebalance|rebalancing|diversification|diversify|allocation|risk)\b',
    ).hasMatch(text)) {
      return 'Asset allocation describes how a portfolio is split across investment types. Diversification spreads exposure; rebalancing moves the mix toward a chosen target. The AI card illustrates moving 10 percentage points from stocks to mutual funds. It is separate sample data from the Portfolio screen and does not change any holdings.';
    }
    if (RegExp(
      r'\b(stock|stocks|equity|equities|share|shares)\b',
    ).hasMatch(text)) {
      return 'A stock represents ownership in a company. Its price can change with business performance, expectations, and market conditions. Returns can include price changes and dividends, but losses are possible. You can also ask about mutual funds, diversification, or the sample portfolio.';
    }
    if (RegExp(r'\b(return|returns|profit|loss|performance)\b').hasMatch(text)) {
      return 'Unrealized profit is current value minus invested value before selling. In the sample portfolio, ₹4,85,230 − ₹3,50,000 = ₹1,35,230, approximately 38.6% of invested value. The app’s projected returns are illustrative, not guaranteed outcomes.';
    }
    return 'This local demo supports stock basics, mutual funds and SIPs, risk and rebalancing, and the sample portfolio. Try “Explain stocks”, “What is a SIP?”, or “Show my investments”. Free-form AI answers will be available when the AI service is connected.';
  }

  void _send([String? prompt]) {
    final question = (prompt ?? _input.text).trim();
    if (question.isEmpty) return;
    setState(() {
      widget.messages.add((user: true, text: question));
      widget.messages.add((user: false, text: _reply(question)));
      _input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Investment Assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                  AnimatedButtonInteraction(
                    child: IconButton(
                      tooltip: 'Close chat',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Demo chat · No live market or account connection',
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
              ),
            ),
            const Divider(height: 1, color: _border),
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  final message =
                      widget.messages[widget.messages.length - 1 - index];
                  return Align(
                    alignment: message.user
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      margin: EdgeInsets.only(
                        bottom: 12,
                        left: message.user ? 24 : 0,
                        right: message.user ? 0 : 24,
                      ),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: message.user
                            ? const Color(0xFFDCFCE7)
                            : _surface,
                        border: Border.all(
                          color: message.user ? _green : _border,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Semantics(
                        liveRegion: !message.user && index == 0,
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: _ink,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (MediaQuery.viewInsetsOf(context).bottom == 0)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final prompt in [
                      'Show my investments',
                      'Explain stocks',
                      'What is a SIP?',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedButtonInteraction(
                          child: ActionChip(
                            elevation: 0,
                            pressElevation: 0,
                            label: Text(
                              prompt,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () => _send(prompt),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 500,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Ask about stocks or investments…',
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedButtonInteraction(
                    child: IconButton.filled(
                      tooltip: 'Send message',
                      onPressed: _input.text.trim().isEmpty
                          ? null
                          : () => _send(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryButtonColor,
                        side: const BorderSide(color: _border),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

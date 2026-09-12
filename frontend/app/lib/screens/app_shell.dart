import 'package:flutter/material.dart';

import '../widgets/animated_app_navigation.dart';
import '../widgets/screen_transition.dart';
import 'home_screen.dart';
import 'invest_screen.dart';
import 'portfolio_screen.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';
import '../services/api_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  final _investmentKey = GlobalKey<InvestScreenState>();
  late final _controller = AnimationController(
    vsync: this,
    duration: screenTransitionDuration,
    value: 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );
  late final List<Widget> _pages = [
    HomeScreen(onNavigate: _select),
    InvestScreen(key: _investmentKey, apiService: widget.apiService),
    const PortfolioScreen(),
    const AiScreen(),
    const ProfileScreen(),
  ];
  int _index = 0;
  int? _previous;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && _previous != null) {
        setState(() => _previous = null);
      }
    });
  }

  void _select(int index) {
    if (index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    setState(() {
      _previous = reduceMotion ? null : _index;
      _index = index;
    });
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _index == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      if (_index == 1 && (_investmentKey.currentState?.handleBack() ?? false)) {
        return;
      }
      _select(0);
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: AnimatedAppNavigation(currentIndex: _index, onTap: _select),
      ),
      body: Stack(
        children: List.generate(_pages.length, (index) {
          final active = index == _index;
          return Positioned.fill(
            child: Offstage(
              offstage: !active && index != _previous,
              child: TickerMode(
                enabled: active || index == _previous,
                child: IgnorePointer(
                  ignoring: !active,
                  child: ExcludeSemantics(
                    excluding: !active,
                    child: FadeTransition(
                      opacity: active ? _curve : ReverseAnimation(_curve),
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.025, 0),
                          end: Offset.zero,
                        ).animate(_curve),
                        child: ExcludeFocus(
                          excluding: !active,
                          child: _pages[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

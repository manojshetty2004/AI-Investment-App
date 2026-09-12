import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_primary_button.dart';

class AuthTabs extends StatelessWidget {
  const AuthTabs({
    super.key,
    required this.registerSelected,
    required this.onLogin,
    required this.onRegister,
  });

  final bool registerSelected;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      border: Border.all(color: appBorderColor),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        _tab('Login', !registerSelected, onLogin),
        const SizedBox(width: 4),
        _tab('Register', registerSelected, onRegister),
      ],
    ),
  );

  Widget _tab(String label, bool selected, VoidCallback onTap) => Expanded(
    child: Semantics(
      selected: selected,
      button: true,
      child: AnimatedButtonInteraction(
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: selected ? () {} : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: selected ? appAccentColor : appBorderColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF15803D)
                        : const Color(0xFF485B77),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

import '../widgets/screen_transition.dart';
import '../widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _background = Color(0xFFF7F9FB);
  static const _surface = Color(0xFFF1F5F9);
  static const _border = Color(0xFFE5E7EB);
  static const _ink = Color(0xFF131C30);
  static const _muted = Color(0xFF657B98);
  static const _green = Color(0xFF00C853);

  void _showDetails(BuildContext context, String title, String message) {
    showModalBottomSheet<void>(
      elevation: 0,
      context: context,
      backgroundColor: _background,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color, Color background) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );

  Widget _row(
    BuildContext context,
    String label,
    String details, {
    Widget? trailing,
  }) => AnimatedButtonInteraction(
    child: InkWell(
      onTap: () => _showDetails(context, label, details),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 49),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
        ),
      ),
    ),
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
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Security & Account Parameters',
                  style: TextStyle(fontSize: 12, color: Color(0xFF485B77)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    color: _surface,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                          border: Border.all(color: _green),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'AS',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF00AF45),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex Sharma',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'alex.sharma@terminal.com',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF485B77),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  elevation: 0,
                  color: _surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: _border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _row(
                        context,
                        'Personal Information',
                        'Alex Sharma\nalex.sharma@terminal.com\n\nThis is a demo profile. Account editing is not connected yet.',
                      ),
                      const Divider(height: 1, thickness: 1, color: _border),
                      _row(
                        context,
                        'Risk Profile',
                        'Low Risk\n\nThis is the sample account risk profile. You can choose a strategy for each investment from Invest.',
                        trailing: _badge(
                          'Low Risk',
                          const Color(0xFF00AF45),
                          const Color(0xFFDCFCE7),
                        ),
                      ),
                      const Divider(height: 1, thickness: 1, color: _border),
                      _row(
                        context,
                        'Linked Demat Account',
                        'The demo account displays an Active status. Live demat account linking is not connected yet.',
                        trailing: _badge(
                          'Active',
                          const Color(0xFF2563EB),
                          const Color(0xFFDBEAFE),
                        ),
                      ),
                      const Divider(height: 1, thickness: 1, color: _border),
                      _row(
                        context,
                        'Security Settings',
                        'Password and account security settings will be available when account services are connected.',
                      ),
                      const Divider(height: 1, thickness: 1, color: _border),
                      _row(
                        context,
                        'Notifications',
                        'Notifications are shown as Enabled for this demo profile. Device notification preferences are not connected yet.',
                        trailing: const Text(
                          'Enabled',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF485B77),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedPrimaryButton(
                  text: 'Logout Account',
                  foregroundColor: const Color(0xFFFF2020),
                  borderSide: const BorderSide(color: _border),
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    SmoothPageRoute<void>(builder: (_) => const LoginScreen()),
                    (_) => false,
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

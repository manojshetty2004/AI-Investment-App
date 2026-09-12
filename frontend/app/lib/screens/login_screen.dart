import '../widgets/auth_tabs.dart';
import '../widgets/screen_transition.dart';
import '../widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _green = Color(0xFF19C45B);
  static const _ink = Color(0xFF141C2C);
  static const _muted = Color(0xFF4B5D75);
  static const _border = Color(0xFFE5E7EB);
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _rememberMe = true;

  void _openRegistration() => Navigator.of(
    context,
  ).push(SmoothPageRoute<void>(builder: (_) => const RegistrationScreen()));

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _textAction(String label, VoidCallback onPressed) {
    return AnimatedButtonInteraction(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: _green,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
      prefixIcon: Icon(icon, size: 21, color: const Color(0xFF687D98)),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _border),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: _green,
                                size: 25,
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  'Tradex',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                              ),
                              _textAction(
                                'Need help?',
                                () => _showMessage(
                                  'Support is not connected yet.',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          AuthTabs(
                            registerSelected: false,
                            onLogin: () {},
                            onRegister: _openRegistration,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Access your AI smart portfolio instantly.',
                            style: TextStyle(fontSize: 14, color: _muted),
                          ),
                          const SizedBox(height: 29),
                          const Text(
                            'EMAIL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: _decoration(
                              'Email or username',
                              Icons.mail_outline_rounded,
                            ),
                            style: const TextStyle(fontSize: 14, color: _ink),
                            keyboardType: TextInputType.text,
                            autofillHints: const [AutofillHints.username],
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your email or username';
                              }
                              return value == 'admin'
                                  ? null
                                  : 'Invalid credentials';
                            },
                          ),
                          const SizedBox(height: 21),
                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            obscureText: _hidePassword,
                            enableSuggestions: false,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.password],
                            style: const TextStyle(fontSize: 14, color: _ink),
                            decoration: _decoration(
                              '••••••••••••',
                              Icons.lock_outline_rounded,
                              suffix: AnimatedButtonInteraction(
                                child: IconButton(
                                  tooltip: _hidePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 21,
                                    color: const Color(0xFF687D98),
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              return value == 'admin'
                                  ? null
                                  : 'Invalid credentials';
                            },
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              AnimatedButtonInteraction(
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _rememberMe = !_rememberMe,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 40,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) => setState(
                                            () => _rememberMe = value ?? false,
                                          ),
                                          activeColor: _green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          side: const BorderSide(color: _muted),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      const Text(
                                        'Remember me',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _textAction(
                                'Forgot Password?',
                                () => _showMessage(
                                  'Password recovery is not connected yet.',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AnimatedPrimaryButton(
                            text: 'Login Securely',
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.of(context).pushReplacement(
                                  SmoothPageRoute(
                                    builder: (_) => const AppShell(),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 22),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: _border)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF687D98),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: _border)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          AnimatedPrimaryButton(
                            text: 'Sign in with Google',
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            color: Colors.white,
                            foregroundColor: _ink,
                            borderSide: const BorderSide(color: _border),
                            onTap: () => _showMessage(
                              'Google sign-in is not connected yet.',
                            ),
                          ),
                          const SizedBox(height: 36),
                          const Spacer(),
                          AnimatedButtonInteraction(
                            child: TextButton(
                              onPressed: _openRegistration,
                              child: const Text.rich(
                                TextSpan(
                                  text: "Don't have an account? ",
                                  children: [
                                    TextSpan(
                                      text: 'Register',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF687D98),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
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
}

import '../widgets/auth_tabs.dart';
import '../widgets/screen_transition.dart';
import '../widgets/animated_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _background = Color(0xFFF7F9FB);
const _surface = Color(0xFFF1F5F9);
const _border = Color(0xFFE5E7EB);
const _ink = Color(0xFF131C30);
const _muted = Color(0xFF485B77);
const _green = Color(0xFF1BC45B);

/// Local registration preview. No account is created or authenticated here.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _phoneForm = GlobalKey<FormState>();
  final _profileForm = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _occupation = TextEditingController();
  final _otp = List.generate(6, (_) => TextEditingController());
  final _otpFocus = List.generate(6, (_) => FocusNode());
  int _step = 0;
  bool _otpRequested = false;
  String? _income;
  String? _experience;
  String? _goal;
  int? _answer;
  String? _error;

  static const _incomes = [
    'Below ₹50,000',
    '₹50,000 – ₹1,00,000',
    '₹1,00,000 – ₹1,50,000',
    '₹1,50,000 – ₹2,50,000',
    'Above ₹2,50,000',
  ];
  static const _answers = [
    'Panic and sell all remaining investments to prevent further losses.',
    'Do nothing and wait for the market to eventually recover.',
    'View it as a buying opportunity and invest more capital.',
  ];

  @override
  void dispose() {
    for (final controller in [_phone, _name, _age, _occupation, ..._otp]) {
      controller.dispose();
    }
    for (final focus in _otpFocus) {
      focus.dispose();
    }
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _step--;
        _error = null;
      });
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      if (!_phoneForm.currentState!.validate()) return;
      if (!_otpRequested) {
        setState(() => _error = 'Tap Get OTP to start the preview.');
        return;
      }
      if (_otp.any((digit) => digit.text.length != 1)) {
        setState(() => _error = 'Enter all six preview code digits.');
        return;
      }
    } else if (_step == 1) {
      final valid = _profileForm.currentState!.validate();
      if (!valid || _income == null || _experience == null || _goal == null) {
        setState(
          () => _error =
              'Complete your details and select income, experience, and a goal.',
        );
        return;
      }
    } else if (_step == 2 && _answer == null) {
      setState(() => _error = 'Select an answer to continue.');
      return;
    }
    setState(() {
      _step++;
      _error = null;
    });
  }

  Widget _text(
    String value, {
    double size = 14,
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

  InputDecoration _decoration(String hint, {Widget? prefix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF657B98)),
    prefixIcon: prefix,
    filled: true,
    fillColor: _surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _green),
    ),
  );

  Widget _button(String label, VoidCallback action, {bool primary = true}) =>
      AnimatedPrimaryButton(
        text: label,
        onTap: action,
        foregroundColor: primary ? primaryButtonColor : _ink,
      );

  Widget _label(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: _text(label, size: 12, color: _muted, bold: true),
  );

  Widget _header() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          AnimatedButtonInteraction(
            child: IconButton(
              tooltip: 'Back',
              onPressed: _back,
              icon: const Icon(Icons.chevron_left, color: _ink),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 44),
            ),
          ),
          Expanded(
            child: _text(
              [
                '',
                'Setup Investor Profile',
                'Risk Suitability Analysis',
                'Registration Preview',
              ][_step],
              size: 18,
              bold: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 8,
        children: [
          _text(
            'STEP ${_step + 1} OF 4',
            size: 12,
            color: const Color(0xFF00AD49),
            bold: true,
          ),
          _text('${(_step + 1) * 25}% Complete', size: 12, color: _muted),
        ],
      ),
      const SizedBox(height: 12),
      LinearProgressIndicator(
        value: (_step + 1) / 4,
        minHeight: 4,
        color: _green,
        backgroundColor: _surface,
        borderRadius: BorderRadius.circular(3),
      ),
      const SizedBox(height: 28),
    ],
  );

  Widget _registration() => Form(
    key: _phoneForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, color: _green, size: 26),
            const SizedBox(width: 14),
            Expanded(child: _text('Tradex', size: 20, bold: true)),
            AnimatedButtonInteraction(
              child: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    elevation: 0,
                    title: const Text('Registration preview'),
                    content: const Text(
                      'Explore the registration screens with sample details. OTP delivery and account creation will be connected later. Use the existing admin login to access the app.',
                    ),
                    actions: [
                      AnimatedButtonInteraction(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ),
                    ],
                  ),
                ),
                child: const Text(
                  'Need help?',
                  style: TextStyle(color: Color(0xFF00AD49)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        AuthTabs(
          registerSelected: true,
          onLogin: () => Navigator.of(context).pop(),
          onRegister: () {},
        ),
        const SizedBox(height: 32),
        _text('Create Account', size: 29, bold: true),
        const SizedBox(height: 8),
        _text(
          'Enter your phone number to receive a verification code.',
          color: _muted,
        ),
        const SizedBox(height: 30),
        _label('PHONE NUMBER'),
        TextFormField(
          key: const ValueKey('registration-phone'),
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: _decoration(
            '98765 43210',
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: Color(0xFF657B98),
                  ),
                  SizedBox(width: 8),
                  Text('+91', style: TextStyle(color: _muted)),
                ],
              ),
            ),
          ),
          validator: (value) =>
              value?.length == 10 ? null : 'Enter a 10-digit phone number',
          onChanged: (_) {
            if (_otpRequested) {
              setState(() {
                _otpRequested = false;
                _error = null;
                for (final digit in _otp) {
                  digit.clear();
                }
              });
            }
          },
        ),
        const SizedBox(height: 16),
        _button(_otpRequested ? 'Reset Preview OTP' : 'Get OTP', () {
          if (!_phoneForm.currentState!.validate()) return;
          setState(() {
            _otpRequested = true;
            _error = null;
            for (final digit in _otp) {
              digit.clear();
            }
          });
          _otpFocus.first.requestFocus();
        }, primary: false),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 5 ? 8 : 0),
                child: TextField(
                  key: ValueKey('otp-$index'),
                  controller: _otp[index],
                  focusNode: _otpFocus[index],
                  enabled: _otpRequested,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  decoration: _decoration('–').copyWith(
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    semanticCounterText: 'Code digit ${index + 1}',
                    labelText: null,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _otpFocus[index + 1].requestFocus();
                    }
                    if (value.isEmpty && index > 0) {
                      _otpFocus[index - 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _text(
          _otpRequested
              ? 'Preview only: enter any six digits. No SMS was sent.'
              : 'Frontend preview — SMS and account creation are not connected.',
          size: 12,
          color: _muted,
        ),
        const SizedBox(height: 26),
      ],
    ),
  );

  Widget _field(
    String label,
    String hint,
    TextEditingController controller, {
    bool age = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _label(label),
      TextFormField(
        key: ValueKey(label),
        controller: controller,
        decoration: _decoration(hint),
        keyboardType: age ? TextInputType.number : TextInputType.text,
        textCapitalization: age
            ? TextCapitalization.none
            : TextCapitalization.words,
        inputFormatters: age
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ]
            : null,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';
          if (age) {
            final parsed = int.tryParse(value);
            if (parsed == null || parsed < 18 || parsed > 120) {
              return 'Enter age 18–120';
            }
          }
          return null;
        },
      ),
    ],
  );

  Widget _choice(String label, bool selected, VoidCallback onSelected) =>
      AnimatedButtonInteraction(
        child: ChoiceChip(
          elevation: 0,
          pressElevation: 0,
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(),
          showCheckmark: false,
          selectedColor: Colors.white,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            fontSize: 13,
            color: selected ? const Color(0xFF00AD49) : _muted,
            fontWeight: FontWeight.w600,
          ),
          side: const BorderSide(color: _border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        ),
      );

  Widget _profile() => Form(
    key: _profileForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field('FULL NAME', 'Enter your full name', _name),
        const SizedBox(height: 22),
        Builder(
          builder: (context) {
            final age = _field('AGE', 'Age', _age, age: true);
            final occupation = _field('OCCUPATION', 'Occupation', _occupation);
            return MediaQuery.sizeOf(context).width < 358
                ? Column(
                    children: [age, const SizedBox(height: 22), occupation],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: age),
                      const SizedBox(width: 12),
                      Expanded(child: occupation),
                    ],
                  );
          },
        ),
        const SizedBox(height: 22),
        _label('MONTHLY INCOME'),
        DropdownButtonFormField<String>(
          elevation: 0,
          initialValue: _income,
          isExpanded: true,
          decoration: _decoration('Select monthly income'),
          hint: const Text(
            'Select monthly income',
            style: TextStyle(fontSize: 14, color: _muted),
          ),
          items: _incomes
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _income = value),
          validator: (value) =>
              value == null ? 'Select your monthly income' : null,
        ),
        const SizedBox(height: 22),
        _label('INVESTMENT EXPERIENCE'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Beginner', 'Intermediate', 'Advanced']
              .map(
                (value) => _choice(
                  value,
                  _experience == value,
                  () => setState(() => _experience = value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 22),
        _label('INVESTMENT GOAL'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Wealth Creation', 'Retirement', 'Passive Income']
              .map(
                (value) => _choice(
                  value,
                  _goal == value,
                  () => setState(() => _goal = value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 26),
      ],
    ),
  );

  Widget _risk() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 20,
              runSpacing: 8,
              children: [
                _text(
                  'QUESTION 1 OF 1',
                  size: 11,
                  color: const Color(0xFF00AD49),
                  bold: true,
                ),
                _text('Risk preference', size: 12, color: _muted),
              ],
            ),
            const SizedBox(height: 24),
            _text(
              'How would you react if your portfolio dropped 20% in a week?',
              size: 16,
              bold: true,
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      for (var i = 0; i < _answers.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Semantics(
            selected: _answer == i,
            child: Material(
              elevation: 0,
              color: _answer == i ? const Color(0xFFDCFCE7) : _surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
                side: BorderSide(color: _answer == i ? _green : _border),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedButtonInteraction(
                child: InkWell(
                  onTap: () => setState(() {
                    _answer = i;
                    _error = null;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _answer == i ? _green : Colors.transparent,
                          ),
                          child: _text(
                            ['A', 'B', 'C'][i],
                            size: 12,
                            bold: true,
                            color: _answer == i ? Colors.white : _muted,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _text(
                            _answers[i],
                            color: _answer == i ? _ink : _muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _completion() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.check_circle_outline, color: _green, size: 56),
      const SizedBox(height: 20),
      _text('Preview complete', size: 25, bold: true),
      const SizedBox(height: 12),
      _text(
        'Thanks, ${_name.text.trim()}. Your selections are ready to review.',
        color: _muted,
      ),
      const SizedBox(height: 24),
      for (final row in [
        ('Experience', _experience!),
        ('Goal', _goal!),
        ('Risk response', _answers[_answer!]),
      ]) ...[
        _label(row.$1.toUpperCase()),
        _text(row.$2),
        const SizedBox(height: 18),
      ],
      _text(
        'No account has been created or saved. Registration and phone verification will be connected later. Only the existing admin login can access the app.',
        size: 13,
        color: _muted,
      ),
      const SizedBox(height: 24),
    ],
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _step == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedScreenContent(
            step: _step,
            child: SingleChildScrollView(
              key: ValueKey(_step),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 28),
                          if (_step > 0) _header(),
                          if (_step == 0)
                            _registration()
                          else if (_step == 1)
                            _profile()
                          else if (_step == 2)
                            _risk()
                          else
                            _completion(),
                          if (_step > 0) const Spacer(),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Semantics(
                                liveRegion: true,
                                child: _text(
                                  _error!,
                                  size: 13,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          _button(
                            [
                              'Verify & Register',
                              'Continue',
                              'Sign Up',
                              'Back to Login',
                            ][_step],
                            _step == 3
                                ? () => Navigator.of(context).pop()
                                : _next,
                          ),
                          if (_step == 0) ...[
                            const SizedBox(height: 32),
                            const Spacer(),
                            AnimatedButtonInteraction(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Color(0xFF657B98)),
                                    children: [
                                      TextSpan(
                                        text: 'Login',
                                        style: TextStyle(
                                          color: Color(0xFF00AD49),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
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
    ),
  );
}

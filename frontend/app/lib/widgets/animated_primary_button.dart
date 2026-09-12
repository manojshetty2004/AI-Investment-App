import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

const buttonAnimationDuration = Duration(milliseconds: 180);
const primaryButtonColor = Color(0xFF22C55E);

/// Shared paint-only feedback; the control's layout and hit target stay stable.
class ButtonPressEffect extends StatelessWidget {
  const ButtonPressEffect({
    super.key,
    required this.pressed,
    required this.child,
    this.enabled = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final bool pressed;
  final bool enabled;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : buttonAnimationDuration;
    final active = pressed && enabled;
    return AnimatedScale(
      scale: active ? 0.95 : 1,
      duration: duration,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: !enabled
            ? 0.45
            : active
            ? 0.88
            : 1,
        duration: duration,
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: const [],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Full-width action with native ink, keyboard access, and a disabled busy state.
class AnimatedPrimaryButton extends StatefulWidget {
  const AnimatedPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.loading = false,
    this.color = Colors.white,
    this.foregroundColor = appInkColor,
    this.borderSide = const BorderSide(color: appBorderColor),
  });

  final String text;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool loading;
  final Color color;
  final Color foregroundColor;
  final BorderSide borderSide;

  @override
  State<AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<AnimatedPrimaryButton> {
  bool _pressed = false;
  bool get _enabled => widget.onTap != null && !widget.loading;

  void _setPressed(bool pressed) {
    if (mounted && _pressed != pressed) setState(() => _pressed = pressed);
  }

  void _activate() {
    if (!_enabled) return;
    _setPressed(false);
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  void didUpdateWidget(covariant AnimatedPrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: _enabled,
    liveRegion: widget.loading,
    label: widget.loading ? '${widget.text}, loading' : widget.text,
    onTap: _enabled ? _activate : null,
    excludeSemantics: true,
    child: GestureDetector(
      // InkWell owns activation, so a tap invokes the callback exactly once.
      excludeFromSemantics: true,
      onTapDown: _enabled ? (_) => _setPressed(true) : null,
      onTapUp: _enabled ? (_) => _setPressed(false) : null,
      onTapCancel: () => _setPressed(false),
      child: ButtonPressEffect(
        pressed: _pressed,
        enabled: _enabled,
        child: Material(
          elevation: 0,
          color: widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: widget.borderSide,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _enabled ? _activate : null,
            onHighlightChanged: _setPressed,
            enableFeedback: false,
            splashFactory: InkRipple.splashFactory,
            splashColor: widget.foregroundColor.withValues(alpha: 0.18),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.loading || widget.icon != null) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: widget.loading
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: widget.foregroundColor,
                                )
                              : IconTheme(
                                  data: IconThemeData(
                                    size: 20,
                                    color: widget.foregroundColor,
                                  ),
                                  child: widget.icon!,
                                ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: widget.foregroundColor,
                          ),
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
    ),
  );
}

/// Adds feedback to native compact controls without taking over their gestures.
/// The native control still handles ripple, focus, semantics, and its callback.
class AnimatedButtonInteraction extends StatefulWidget {
  const AnimatedButtonInteraction({super.key, required this.child});
  final Widget child;

  @override
  State<AnimatedButtonInteraction> createState() =>
      _AnimatedButtonInteractionState();
}

class _AnimatedButtonInteractionState extends State<AnimatedButtonInteraction> {
  int? _pointer;
  Offset? _origin;
  bool _pressed = false;

  bool get _enabled {
    final child = widget.child;
    if (child is ButtonStyleButton) {
      return child.onPressed != null || child.onLongPress != null;
    }
    if (child is IconButton) return child.onPressed != null;
    if (child is ChoiceChip) return child.onSelected != null;
    if (child is ActionChip) return child.onPressed != null;
    if (child is InkWell) {
      return child.onTap != null || child.onLongPress != null;
    }
    return true;
  }

  void _reset() {
    _pointer = null;
    _origin = null;
    if (_pressed && mounted) setState(() => _pressed = false);
  }

  @override
  void didUpdateWidget(covariant AnimatedButtonInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) {
      _pointer = null;
      _origin = null;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (event) {
      if (!_enabled || _pointer != null) return;
      _pointer = event.pointer;
      _origin = event.position;
      setState(() => _pressed = true);
    },
    onPointerMove: (event) {
      if (_pointer == event.pointer &&
          (event.position - _origin!).distance > 18) {
        _reset();
      }
    },
    onPointerCancel: (event) {
      if (_pointer == event.pointer) _reset();
    },
    onPointerUp: (event) {
      if (_pointer != event.pointer) return;
      final box = context.findRenderObject() as RenderBox?;
      final inside =
          box != null &&
          (Offset.zero & box.size).contains(box.globalToLocal(event.position));
      if (_enabled && _pressed && inside) HapticFeedback.lightImpact();
      _reset();
    },
    child: ButtonPressEffect(
      pressed: _pressed,
      enabled: _enabled,
      child: Theme(
        data: Theme.of(context).copyWith(
          textButtonTheme: const TextButtonThemeData(
            style: AppTheme.buttonStyle,
          ),
          iconButtonTheme: const IconButtonThemeData(
            style: AppTheme.buttonStyle,
          ),
          chipTheme: Theme.of(context).chipTheme.copyWith(
            elevation: 0,
            pressElevation: 0,
            backgroundColor: Colors.white,
            selectedColor: Colors.white,
            side: const BorderSide(color: appBorderColor),
          ),
        ),
        child: widget.child,
      ),
    ),
  );
}

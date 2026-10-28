import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'bf_icons.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String v) => _emailRe.hasMatch(v.trim());

/// Shared chrome for the sign-in, sign-up and reset pages: the dark gradient
/// with the top glow, a back chevron, and a scrolling body that keeps the
/// focused field above the keyboard.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: BF.canvas,
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: BF.bgGradient),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.35, -1),
                    radius: 1.25,
                    colors: [
                      BF.teal.withValues(alpha: .26),
                      BF.acc.withValues(alpha: .14),
                      Colors.transparent,
                    ],
                    stops: const [0, .38, .8],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(26, 8, 26, 32 + inset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Back',
                      child: InkResponse(
                        onTap: () => Navigator.of(context).maybePop(),
                        radius: 24,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: BFIcon(
                              BFIconType.chevronLeft,
                              color: BF.whiteA(.7),
                              size: 20,
                              strokeWidth: 2.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      style: BF.sans(
                        32,
                        800,
                        color: BF.white,
                        height: 1.05,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: BF.sans(
                        14,
                        400,
                        color: BF.whiteA(.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...children,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Labelled text input for the auth forms. Owns no state besides the
/// show/hide toggle; the page supplies the controller so it can read and
/// validate on submit.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final VoidCallback? onChanged;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late final FocusNode _focus = FocusNode()..addListener(() => setState(() {}));
  late bool _hidden = widget.obscure;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    final focused = _focus.hasFocus;
    final border = hasError
        ? BF.gold
        : focused
        ? BF.acc
        : BF.inkA(.16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: BF.sans(12, 600, color: BF.whiteA(.6))),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            color: focused ? BF.whiteA(.09) : BF.field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: _hidden,
                  keyboardType: widget.keyboardType,
                  autofillHints: widget.autofillHints,
                  textInputAction: widget.textInputAction,
                  autocorrect: false,
                  enableSuggestions: !widget.obscure,
                  cursorColor: BF.acc,
                  style: BF.sans(15.5, 500, color: BF.ink),
                  onChanged: (_) => widget.onChanged?.call(),
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.hint,
                    hintStyle: BF.sans(15.5, 500, color: BF.inkA(.35)),
                  ),
                ),
              ),
              if (widget.obscure)
                Semantics(
                  button: true,
                  label: _hidden ? 'Show password' : 'Hide password',
                  child: InkResponse(
                    onTap: () => setState(() => _hidden = !_hidden),
                    radius: 24,
                    child: SizedBox(
                      width: 56,
                      height: 52,
                      child: Center(
                        child: Text(
                          _hidden ? 'Show' : 'Hide',
                          style: BF.sans(12, 700, color: BF.whiteA(.55)),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 14),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.error!,
            style: BF.sans(12, 600, color: BF.goldInk, height: 1.3),
          ),
        ],
      ],
    );
  }
}

/// Inline text link, e.g. "Forgot password?" or "Create account".
class AuthLink extends StatelessWidget {
  const AuthLink(this.label, {super.key, required this.onTap, this.color});

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              label,
              style: BF.sans(13.5, 700, color: color ?? BF.plum),
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner for a form-level error (as opposed to a per-field one).
class AuthBanner extends StatelessWidget {
  const AuthBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BF.waitBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BF.gold.withValues(alpha: .35)),
      ),
      child: Text(
        message,
        style: BF.sans(13, 600, color: BF.goldInk, height: 1.4),
      ),
    );
  }
}

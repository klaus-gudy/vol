import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common.dart';

/// Password reset request. There is no mail service behind the prototype, so
/// this only shows the confirmation — and, like a real one, it confirms for
/// any well-formed email so it can't be used to discover which have accounts.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!isValidEmail(_email.text)) {
      setState(() => _error = 'Enter a valid email.');
      return;
    }
    setState(() {
      _error = null;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AuthScaffold(
        title: 'Check your email',
        subtitle:
            "If an account exists for ${_email.text.trim()}, we've sent a link "
            'to reset your password.',
        children: [
          BFButton(
            label: 'Back to sign in',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: 'Reset password',
      subtitle: "Enter your email and we'll send you a reset link.",
      children: [
        AuthField(
          controller: _email,
          label: 'Email',
          hint: 'you@studio.com',
          error: _error,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
        ),
        const SizedBox(height: 24),
        BFButton(label: 'Send reset link', onTap: _submit),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Remembered it? Go back to sign in.',
            style: BF.sans(13, 500, color: BF.whiteA(.5)),
          ),
        ),
      ],
    );
  }
}

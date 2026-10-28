import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

/// Email + password sign-in, pushed from the role picker.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _formError = null;
      _emailError = isValidEmail(_email.text) ? null : 'Enter a valid email.';
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    final error = AppScope.of(
      context,
    ).signInWithEmail(_email.text, _password.text);
    if (error != null) {
      setState(() => _formError = error);
      return;
    }
    // Signing in swaps the root to the app shell; drop this page off the
    // navigator so it doesn't sit on top of it.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: "Sign in to run today's chairs and queue.",
      children: [
        if (_formError != null) ...[
          AuthBanner(_formError!),
          const SizedBox(height: 16),
        ],
        AuthField(
          controller: _email,
          label: 'Email',
          hint: 'you@studio.com',
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 16),
        AuthField(
          controller: _password,
          label: 'Password',
          hint: 'Your password',
          error: _passwordError,
          obscure: true,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AuthLink(
            'Forgot password?',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ForgotPasswordScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        BFButton(label: 'Sign in', onTap: _submit),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'New to Braidflow?',
              style: BF.sans(13.5, 500, color: BF.whiteA(.6)),
            ),
            AuthLink(
              'Create account',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

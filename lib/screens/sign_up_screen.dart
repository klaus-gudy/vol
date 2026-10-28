import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/common.dart';
import 'sign_in_screen.dart';

/// Account creation for the owner and front-desk roles. Braiders don't sign
/// themselves up — the owner adds them to the roster.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Role _role = Role.supervisor;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _formError = null;
      _nameError = _name.text.trim().isEmpty ? 'Enter your name.' : null;
      _emailError = isValidEmail(_email.text) ? null : 'Enter a valid email.';
      _passwordError = _password.text.length < 8
          ? 'Use at least 8 characters.'
          : null;
      _confirmError = _confirm.text == _password.text
          ? null
          : "Passwords don't match.";
    });
    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    final error = AppScope.of(context).signUp(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      role: _role,
    );
    if (error != null) {
      setState(() => _formError = error);
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Set up your login for the studio.',
      children: [
        if (_formError != null) ...[
          AuthBanner(_formError!),
          const SizedBox(height: 16),
        ],
        AuthField(
          controller: _name,
          label: 'Full name',
          hint: 'Sandra Musa',
          error: _nameError,
          keyboardType: TextInputType.name,
          autofillHints: const [AutofillHints.name],
        ),
        const SizedBox(height: 16),
        AuthField(
          controller: _email,
          label: 'Email',
          hint: 'you@studio.com',
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 16),
        Text('I am the', style: BF.sans(12, 600, color: BF.whiteA(.6))),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _RoleChoice(
                label: 'Owner',
                selected: _role == Role.owner,
                onTap: () => setState(() => _role = Role.owner),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RoleChoice(
                label: 'Supervisor',
                selected: _role == Role.supervisor,
                onTap: () => setState(() => _role = Role.supervisor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuthField(
          controller: _password,
          label: 'Password',
          hint: 'At least 8 characters',
          error: _passwordError,
          obscure: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 16),
        AuthField(
          controller: _confirm,
          label: 'Confirm password',
          hint: 'Repeat password',
          error: _confirmError,
          obscure: true,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
        ),
        const SizedBox(height: 24),
        BFButton(label: 'Create account', onTap: _submit),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: BF.sans(13.5, 500, color: BF.whiteA(.6)),
            ),
            AuthLink(
              'Sign in',
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? BF.acc.withValues(alpha: .18) : BF.field,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? BF.acc : BF.inkA(.16)),
            ),
            child: Text(
              label,
              style: BF.sans(
                14,
                700,
                color: selected ? BF.white : BF.whiteA(.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

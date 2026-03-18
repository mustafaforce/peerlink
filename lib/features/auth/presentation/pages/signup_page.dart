import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../widgets/auth_scaffold.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await AppDependencies.authRepository.signUp(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. Check your email for the Supabase magic/confirmation link.',
            ),
          ),
        );

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (Route<dynamic> route) => false,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Sign up failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create Account',
      subtitle: 'Sign up and verify email from your inbox.',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Your full name',
              ),
              validator: (String? value) {
                final String input = value?.trim() ?? '';
                if (input.isEmpty) {
                  return 'Full name is required';
                }
                if (input.length < 3) {
                  return 'Enter at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              validator: (String? value) {
                final String input = value?.trim() ?? '';
                if (input.isEmpty) {
                  return 'Email is required';
                }
                if (!input.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'At least 6 characters',
              ),
              validator: (String? value) {
                final String input = value ?? '';
                if (input.isEmpty) {
                  return 'Password is required';
                }
                if (input.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
              ),
              validator: (String? value) {
                if ((value ?? '').isEmpty) {
                  return 'Confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _signup,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRouter.login),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

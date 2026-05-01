import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../cubit/cubit.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(authRepository: AppDependencies.authRepository),
      child: const _ForgotPasswordForm(),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().resetPassword(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F4),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == Status.success && state.isPasswordReset) {
            setState(() => _emailSent = true);
          }
          if (state.status == Status.failure && state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<AuthCubit>().resetStatus();
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state.status == Status.loading;
            return AuthScaffold(
              title: 'Reset Password',
              subtitle: _emailSent
                  ? 'Check your email for reset instructions.'
                  : 'Enter your email to receive reset instructions.',
              child: _emailSent
                  ? Column(
                      children: [
                        const Icon(Icons.check_circle, size: 64, color: Color(0xFF1AAE39)),
                        const SizedBox(height: 16),
                        const Text('Email sent! Check your inbox.'),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed(
                              AppRouter.login,
                            ),
                            child: const Text('Back to Login'),
                          ),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@example.com',
                            ),
                            validator: (value) {
                              final input = value?.trim() ?? '';
                              if (input.isEmpty) return 'Email is required';
                              if (!input.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _sendReset,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Send Reset Email'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pushReplacementNamed(
                                        AppRouter.login,
                                      ),
                              child: const Text('Remember your password? Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/router/app_router.dart';
import '../cubit/cubit.dart';
import '../widgets/auth_scaffold.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(authRepository: AppDependencies.authRepository),
      child: _OtpForm(email: email),
    );
  }
}

class _OtpForm extends StatefulWidget {
  const _OtpForm({required this.email});

  final String email;

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().verifyOtp(
      email: widget.email,
      token: _otpController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F4),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == Status.success && state.isEmailVerified) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Email verified!')));
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.login,
              (_) => false,
            );
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
              title: 'Verify Email',
              subtitle: 'Enter the OTP sent to ${widget.email}',
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'OTP Code',
                        hintText: '6-digit code',
                        counterText: '',
                      ),
                      validator: (value) {
                        final input = value?.trim() ?? '';
                        if (input.isEmpty) return 'OTP is required';
                        if (input.length != 6) return 'OTP must be 6 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verify,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Verify'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                try {
                                  await AppDependencies.authRepository
                                      .resendConfirmationEmail(email: widget.email);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(content: Text('OTP resent!')),
                                    );
                                } catch (_) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(content: Text('Failed to resend OTP')),
                                    );
                                }
                              },
                        child: const Text('Resend OTP'),
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

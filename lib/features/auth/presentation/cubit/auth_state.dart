import 'package:equatable/equatable.dart';

enum Status { initial, loading, success, failure }

class BaseState extends Equatable {
  const BaseState({
    this.status = Status.initial,
    this.error,
  });

  final Status status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}

class AuthState extends BaseState {
  const AuthState({
    super.status,
    super.error,
    this.isEmailVerified = false,
    this.isPasswordReset = false,
  });

  final bool isEmailVerified;
  final bool isPasswordReset;

  @override
  AuthState copyWith({
    Status? status,
    String? error,
    bool? isEmailVerified,
    bool? isPasswordReset,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPasswordReset: isPasswordReset ?? this.isPasswordReset,
    );
  }

  @override
  List<Object?> get props => [status, error, isEmailVerified, isPasswordReset];
}

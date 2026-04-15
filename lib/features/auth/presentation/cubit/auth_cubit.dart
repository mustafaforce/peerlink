import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  final AuthRepository _authRepository;

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.signInWithPassword(
        email: email,
        password: password,
      );

      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  Future<void> signInWithOtp({required String email}) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.signInWithOtp(email: email);
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.verifyOtp(
        email: email,
        token: token,
      );

      emit(state.copyWith(status: Status.success, isEmailVerified: true));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.resetPasswordForEmail(email: email);
      emit(state.copyWith(status: Status.success, isPasswordReset: true));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.updatePassword(newPassword: newPassword);
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.signOut();
      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, error: e.toString()));
    }
  }

  bool get isEmailConfirmed => _authRepository.isEmailConfirmed;

  String? get currentUserId => _authRepository.currentUserId;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthAvatarUpdateRequested>(_onAuthAvatarUpdateRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthFailure('Не удалось войти'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthFailure('Не удалось зарегистрироваться'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        await _authRepository.updateProfile(
          fullName: event.fullName,
          company: event.company,
        );
        final updatedUser = await _authRepository.getCurrentUser();
        if (updatedUser != null) {
          emit(AuthAuthenticated(updatedUser));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthAuthenticated(currentState.user));
      }
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthAvatarUpdateRequested(
    AuthAvatarUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(AuthLoading());
      try {
        final newUrl = await _authRepository.updateAvatar(event.imageFile);
        if (newUrl != null) {
          final updatedUser = await _authRepository.getCurrentUser();
          if (updatedUser != null) {
            emit(AuthAuthenticated(updatedUser));
          }
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthAuthenticated(currentState.user));
      }
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:ready_pro/repositories/auth_repository.dart';
import 'package:ready_pro/models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:async';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  Profile? _cachedUser;

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
    if (_cachedUser != null) {
      emit(AuthAuthenticated(_cachedUser!));
      return;
    }
    
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _cachedUser = user;
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
        _cachedUser = user;
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
        _cachedUser = user;
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
        // Принудительно обновляем кэш после редактирования
        final updatedUser = await _authRepository.getCurrentUser();
        if (updatedUser != null) {
          _cachedUser = updatedUser;
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
    _cachedUser = null; // Очищаем кэш при выходе
    emit(AuthUnauthenticated());
    try {
      await _authRepository
          .signOut()
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (e) {
      debugPrint('SignOut timeout: $e');
    } catch (e) {
      debugPrint('SignOut error: $e');
    }
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
          // Принудительно обновляем кэш после смены аватара
          final updatedUser = await _authRepository.getCurrentUser();
          if (updatedUser != null) {
            _cachedUser = updatedUser;
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

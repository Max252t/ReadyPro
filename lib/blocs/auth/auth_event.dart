import 'package:equatable/equatable.dart';
import 'package:ready_pro/models/user.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  AuthSignUpRequested(this.email, this.password, this.fullName);
  @override
  List<Object?> get props => [email, password, fullName];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthAvatarUpdateRequested extends AuthEvent {
  final dynamic imageFile;
  AuthAvatarUpdateRequested(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}

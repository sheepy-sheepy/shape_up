// lib/presentation/blocs/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthLogin(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthLoginWithUser extends AuthEvent {
  final User user;

  const AuthLoginWithUser(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUpdateUser extends AuthEvent {
  final User user;

  const AuthUpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLogout extends AuthEvent {}
// lib/presentation/blocs/auth/auth_state.dart
part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool emailUnconfirmed;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,
    this.emailUnconfirmed = false,
  });

  const AuthState.initial()
      : isAuthenticated = false,
        user = null,
        isLoading = false,
        error = null,
        emailUnconfirmed = false;

  const AuthState.unconfirmedEmail()
      : isAuthenticated = false,
        user = null,
        isLoading = false,
        error = 'Пожалуйста, подтвердите email перед входом',
        emailUnconfirmed = true;

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? emailUnconfirmed,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      emailUnconfirmed: emailUnconfirmed ?? this.emailUnconfirmed,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, user, isLoading, error, emailUnconfirmed];
}
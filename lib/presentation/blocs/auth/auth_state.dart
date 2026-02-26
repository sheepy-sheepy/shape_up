// lib/presentation/blocs/auth/auth_state.dart
part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;
  final bool emailUnconfirmed;
  final bool needsOnboarding; // Добавлено поле

  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,
    this.emailUnconfirmed = false,
    this.needsOnboarding = false,
  });

  const AuthState.initial()
      : isAuthenticated = false,
        user = null,
        isLoading = false,
        error = null,
        emailUnconfirmed = false,
        needsOnboarding = false;

  const AuthState.unconfirmedEmail()
      : isAuthenticated = false,
        user = null,
        isLoading = false,
        error = 'Пожалуйста, подтвердите email перед входом',
        emailUnconfirmed = true,
        needsOnboarding = false;

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
    bool? emailUnconfirmed,
    bool? needsOnboarding,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      emailUnconfirmed: emailUnconfirmed ?? this.emailUnconfirmed,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated, 
    user, 
    isLoading, 
    error, 
    emailUnconfirmed,
    needsOnboarding
  ];
}
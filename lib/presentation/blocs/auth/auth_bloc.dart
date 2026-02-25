// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/../../domain/entities/user.dart';
import '/../../data/datasources/remote/supabase_service.dart';
import '/../../data/repositories/app_repository_provider.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLoginWithUser>(_onAuthLoginWithUser);
    on<AuthUpdateUser>(_onAuthUpdateUser);
    on<AuthLogout>(_onAuthLogout);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final session = SupabaseService.supabase.auth.currentSession;
      final supabaseUser = SupabaseService.supabase.auth.currentUser;
      
      if (session != null && supabaseUser != null) {
        if (supabaseUser.emailConfirmedAt != null) {
          final userData = await SupabaseService.getUserData(supabaseUser.id);
          final user = User.fromJson(userData);
          
          // Также проверяем локальное хранилище
          final hasCompletedParams = await AppRepositoryProvider.auth.getInitialParamsCompleted(user.id);
          
          emit(state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
          ));
        } else {
          await SupabaseService.signOut();
          emit(const AuthState.unconfirmedEmail());
        }
      } else {
        emit(const AuthState.initial());
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final result = await SupabaseService.signIn(
        event.email, 
        event.password
      );
      
      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        emit(state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: result['message'] as String?,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthLoginWithUser(AuthLoginWithUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      isAuthenticated: true,
      user: event.user,
      isLoading: false,
    ));
  }

  Future<void> _onAuthUpdateUser(AuthUpdateUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      isAuthenticated: true,
      user: event.user,
    ));
  }

  Future<void> _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await SupabaseService.signOut();
    emit(const AuthState.initial());
  }
}
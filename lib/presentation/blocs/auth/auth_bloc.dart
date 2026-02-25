// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/remote/supabase_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Проверка текущей сессии
      final session = SupabaseService.supabase.auth.currentSession;
      final user = SupabaseService.supabase.auth.currentUser;
      
      if (session != null && user != null) {
        // Проверяем, подтвержден ли email
        if (user.emailConfirmedAt != null) {
          // Получаем данные пользователя из базы
          final userData = await SupabaseService.getUserData(user.id);
          emit(state.copyWith(
            isAuthenticated: true,
            user: userData,
            isLoading: false,
          ));
        } else {
          // Email не подтвержден - выходим
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
        final user = result['user'] as UserModel;
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

  Future<void> _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await SupabaseService.signOut();
    emit(const AuthState.initial());
  }
}
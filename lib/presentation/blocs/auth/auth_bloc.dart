// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final session = SupabaseService.supabase.auth.currentSession;
      final supabaseUser = SupabaseService.supabase.auth.currentUser;

      if (session != null && supabaseUser != null) {
        if (supabaseUser.emailConfirmedAt != null) {
          // Получаем данные из Supabase
          final userData = await SupabaseService.getUserData(supabaseUser.id);
          final user = User.fromJson(userData);

          // Принудительно синхронизируем с локальной БД
          try {
            final existingUser =
                await AppRepositoryProvider.auth.getUserById(user.id);
            if (existingUser == null) {
              await AppRepositoryProvider.auth.createUser(user);
            } else {
              await AppRepositoryProvider.auth.updateUser(user);
            }
            debugPrint('✅ User synced with local DB');
          } catch (e) {
            debugPrint('⚠️ Local DB sync error: $e');
          }

          // Проверяем наличие всех необходимых параметров
          final hasParams = user.height != null &&
              user.weight != null &&
              user.birthDate != null &&
              user.gender != null &&
              user.goal != null &&
              user.activityLevel != null;

          debugPrint('📊 User data from Supabase:');
          debugPrint('  - height: ${user.height}');
          debugPrint('  - weight: ${user.weight}');
          debugPrint('  - birthDate: ${user.birthDate}');
          debugPrint(
              '  - hasCompletedInitialParams: ${user.hasCompletedInitialParams}');
          debugPrint('  - hasParams from data: $hasParams');

          // Используем комбинированную проверку
          final shouldShowOnboarding =
              !user.hasCompletedInitialParams || !hasParams;

          emit(state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
            needsOnboarding: shouldShowOnboarding,
          ));
        } else {
          await SupabaseService.signOut();
          emit(const AuthState.unconfirmedEmail());
        }
      } else {
        emit(const AuthState.initial());
      }
    } catch (e) {
      debugPrint('❌ Auth check error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final result = await SupabaseService.signIn(event.email, event.password);

      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        final user = User.fromJson(userData);

        // Сохраняем в локальную БД и синхронизируем данные
        try {
          final existingUser =
              await AppRepositoryProvider.auth.getUserById(user.id);
          if (existingUser == null) {
            // Новый пользователь - создаем запись
            await AppRepositoryProvider.auth.createUser(user);
            debugPrint(
                '✅ User created in local DB with hasCompletedInitialParams: ${user.hasCompletedInitialParams}');
          } else {
            debugPrint('✅ User exists in local DB, skipping creation');
          }

          // ВАЖНО: Синхронизируем измерения тела из Supabase
          if (user.hasCompletedInitialParams) {
            await AppRepositoryProvider.body
                .syncMeasurementsFromSupabase(user.id);
          }
        } catch (e) {
          debugPrint('⚠️ Local DB error: $e');
        }

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

  Future<void> _onAuthLoginWithUser(
      AuthLoginWithUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      isAuthenticated: true,
      user: event.user,
      isLoading: false,
    ));
  }

  Future<void> _onAuthUpdateUser(
      AuthUpdateUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      isAuthenticated: true,
      user: event.user,
    ));
  }

  Future<void> _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    // НЕ обновляем локальную БД при выходе
    // Просто очищаем состояние
    emit(const AuthState.initial());
  }
}

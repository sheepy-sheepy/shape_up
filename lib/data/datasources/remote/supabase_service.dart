import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shape_up/data/models/user_model.dart';
import 'package:shape_up/domain/usecases/calculate_nutrition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

// Загрузка начальных продуктов из CSV
  static Future<void> loadInitialFoods() async {
    try {
      // Проверяем, есть ли уже продукты в базе
      final countResponse = await supabase
          .from('foods')
          .select('count')
          .eq('is_custom', false)
          .maybeSingle();

      // Если продукты уже есть, выходим
      if (countResponse != null && countResponse['count'] > 0) {
        debugPrint('✅ Foods already loaded, skipping initialization');
        return;
      }

      // Загружаем из CSV
      final csvData = await rootBundle.loadString('assets/data/foods.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

      // Пропускаем заголовок
      final foods = <Map<String, dynamic>>[];
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 5) {
          foods.add({
            'name': row[0].toString(),
            'calories': double.parse(row[1].toString()),
            'proteins': double.parse(row[2].toString()),
            'fats': double.parse(row[3].toString()),
            'carbs': double.parse(row[4].toString()),
            'is_custom': false,
            'user_id': null, // Важно: для общих продуктов user_id = null
          });
        }
      }

      // Вставляем пачками по 50 записей
      for (var i = 0; i < foods.length; i += 50) {
        final batch = foods.skip(i).take(50).toList();
        try {
          await supabase.from('foods').insert(batch);
          debugPrint(
              '✅ Inserted batch ${i ~/ 50 + 1} of ${(foods.length / 50).ceil()}');
        } catch (e) {
          debugPrint('❌ Error inserting batch: $e');
        }
      }

      debugPrint('✅ Successfully loaded ${foods.length} initial foods');
    } catch (e) {
      debugPrint('❌ Error loading initial foods: $e');
    }
  }

// Регистрация пользователя
  static Future<Map<String, dynamic>> signUp(
      String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Пользователь создан, но email не подтвержден
        // Данные пользователя будут в таблице users после подтверждения email
        return {
          'success': true,
          'message':
              'Письмо с подтверждением отправлено на вашу почту. Пожалуйста, подтвердите email для входа.',
          'user': response.user,
        };
      }
      return {
        'success': false,
        'message': 'Ошибка при регистрации',
      };
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      return {
        'success': false,
        'message': _getFriendlyErrorMessage(e.message),
      };
    } catch (e) {
      debugPrint('Error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

// Получение данных пользователя
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final response =
          await supabase.from('users').select().eq('id', userId).single();

      debugPrint('📥 Raw user data from Supabase: $response');

      // Проверяем и преобразуем has_completed_initial_params
      if (response.containsKey('has_completed_initial_params')) {
        final value = response['has_completed_initial_params'];
        // Преобразуем в булево значение, если оно пришло как число
        if (value is int) {
          response['has_completed_initial_params'] = value == 1;
        } else if (value is bool) {
          response['has_completed_initial_params'] = value;
        } else {
          response['has_completed_initial_params'] = false;
        }
      }

      return response;
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      // Если пользователя нет в таблице, возвращаем базовые данные
      final user = supabase.auth.currentUser;
      if (user != null) {
        // user.createdAt уже строка, не нужно вызывать toIso8601String
        return {
          'id': user.id,
          'email': user.email,
          'created_at': user.createdAt ?? DateTime.now().toIso8601String(),
          'has_completed_initial_params': false,
        };
      }
      rethrow;
    }
  }

  // Повторная отправка письма подтверждения
  static Future<Map<String, dynamic>> resendConfirmationEmail(
      String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'com.example.shape_up://login-callback',
      );

      return {
        'success': true,
        'message': 'Письмо с подтверждением отправлено повторно',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

// Вход пользователя (только с подтвержденным email)
  static Future<Map<String, dynamic>> signIn(
      String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          await supabase.auth.signOut();
          return {
            'success': false,
            'message': 'Пожалуйста, подтвердите email перед входом',
            'emailUnconfirmed': true,
          };
        }

        final userData = await getUserData(response.user!.id);

        // Явно проверяем значение
        final hasCompletedParams =
            userData['has_completed_initial_params'] == true;

        debugPrint('📊 User data from Supabase after conversion:');
        debugPrint(
            '  - hasCompletedInitialParams raw: ${userData['has_completed_initial_params']}');
        debugPrint(
            '  - hasCompletedInitialParams converted: $hasCompletedParams');

        return {
          'success': true,
          'user': userData,
          'hasCompletedParams': hasCompletedParams,
        };
      }
      return {
        'success': false,
        'message': 'Неверный email или пароль',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getFriendlyErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

// Сохранение начальных параметров пользователя
  static Future<Map<String, dynamic>> saveInitialParams(
      Map<String, dynamic> params) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updateData = {
        'height': params['height'],
        'weight': params['weight'],
        'neck_circumference': params['neckCircumference'],
        'waist_circumference': params['waistCircumference'],
        'hip_circumference': params['hipCircumference'],
        'gender': params['gender'],
        'goal': params['goal'],
        'activity_level': params['activityLevel'],
        'birth_date':
            (params['birthDate'] as DateTime).toIso8601String().split('T')[0],
        'has_completed_initial_params': true,
      };

      debugPrint('Updating Supabase user with: $updateData');

      final response =
          await supabase.from('users').update(updateData).eq('id', user.id);

      debugPrint('Supabase update response: $response');

      // Создаем первую запись измерений в Supabase
      await supabase.from('body_measurements').insert({
        'user_id': user.id,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'weight': params['weight'],
        'neck_circumference': params['neckCircumference'],
        'waist_circumference': params['waistCircumference'],
        'hip_circumference': params['hipCircumference'],
        'body_fat_percentage': _calculateBodyFatPercentage(params),
      });

      return {'success': true, 'message': 'Parameters saved'};
    } catch (e) {
      debugPrint('Error saving initial params: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

// Вспомогательный метод для расчета % жира
  static double _calculateBodyFatPercentage(Map<String, dynamic> params) {
    final calculator = CalculateNutrition();
    return calculator.calculateBodyFatPercentage(
      waist: params['waistCircumference'],
      neck: params['neckCircumference'],
      height: params['height'],
      gender: params['gender'],
      hip: params['hipCircumference'],
    );
  }

  // Получение продуктов (общие + пользовательские)
  static Future<List<Map<String, dynamic>>> getFoods(String searchQuery) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final query = supabase
        .from('foods')
        .select()
        .or('is_custom.is.false,and(is_custom.is.true,user_id.eq.${user.id})');

    if (searchQuery.isNotEmpty) {
      query.ilike('name', '%$searchQuery%');
    }

    query.order('is_custom', ascending: false).order('name');

    final response = await query;
    return response;
  }

  // Добавление пользовательского продукта
  static Future<void> addCustomFood(Map<String, dynamic> foodData) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('foods').insert({
      ...foodData,
      'is_custom': true,
      'user_id': user.id,
    });
  }

  // Добавление записи о приеме пищи
  static Future<void> addFoodEntry(Map<String, dynamic> entryData) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('food_entries').insert({
      ...entryData,
      'user_id': user.id,
    });
  }

  // Получение записей о приеме пищи за день
  static Future<List<Map<String, dynamic>>> getFoodEntries(
      DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final dateStr = date.toIso8601String().split('T')[0];

    final response = await supabase.from('food_entries').select('''
          *,
          foods (*)
        ''').eq('user_id', user.id).eq('date', dateStr);

    return response;
  }

  // Добавление записи о воде
  static Future<void> addWaterEntry(int ml, DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final dateStr = date.toIso8601String().split('T')[0];

    await supabase.from('water_entries').insert({
      'user_id': user.id,
      'date': dateStr,
      'ml': ml,
    });
  }

// Получение записей о воде за день
  static Future<int> getTotalWater(DateTime date) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final dateStr = date.toIso8601String().split('T')[0];

    final response = await supabase
        .from('water_entries')
        .select('ml')
        .eq('user_id', user.id)
        .eq('date', dateStr);

    if (response.isEmpty) return 0;

    // Исправлено: суммируем значения
    int total = 0;
    for (var entry in response) {
      total += entry['ml'] as int;
    }
    return total;
  }

  // Добавление фотографий прогресса
  static Future<void> addProgressPhotos({
    required String frontPhoto,
    required String backPhoto,
    required String leftSidePhoto,
    required String rightSidePhoto,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final today = DateTime.now().toIso8601String().split('T')[0];

    // Загружаем фото в Storage
    final frontUrl = await _uploadPhoto(frontPhoto, 'front');
    final backUrl = await _uploadPhoto(backPhoto, 'back');
    final leftUrl = await _uploadPhoto(leftSidePhoto, 'left');
    final rightUrl = await _uploadPhoto(rightSidePhoto, 'right');

    await supabase.from('photos').insert({
      'user_id': user.id,
      'date': today,
      'front_photo': frontUrl,
      'back_photo': backUrl,
      'left_side_photo': leftUrl,
      'right_side_photo': rightUrl,
    });
  }

  // Загрузка фото в Storage
  static Future<String> _uploadPhoto(String filePath, String type) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fileName =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$type.jpg';
    final file = await rootBundle
        .load(filePath); // В реальном приложении используйте File

    await supabase.storage
        .from('progress-photos')
        .uploadBinary(fileName, file.buffer.asUint8List());

    final publicUrl =
        supabase.storage.from('progress-photos').getPublicUrl(fileName);

    return publicUrl;
  }

  // Получение данных для аналитики
  static Future<Map<String, dynamic>> getAnalyticsData({
    required String type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    switch (type) {
      case 'weight':
        final data = await supabase
            .from('body_measurements')
            .select('date, weight')
            .eq('user_id', user.id)
            .not('weight', 'is', null)
            .order('date');
        return {'type': 'weight', 'data': data};

      case 'bodyFat':
        final data = await supabase
            .from('body_measurements')
            .select('date, body_fat_percentage')
            .eq('user_id', user.id)
            .not('body_fat_percentage', 'is', null)
            .order('date');
        return {'type': 'bodyFat', 'data': data};

      case 'measurements':
        final data = await supabase
            .from('body_measurements')
            .select(
                'date, neck_circumference, waist_circumference, hip_circumference')
            .eq('user_id', user.id)
            .order('date');
        return {'type': 'measurements', 'data': data};

      case 'photos':
        final data = await supabase
            .from('photos')
            .select(
                'date, front_photo, back_photo, left_side_photo, right_side_photo')
            .eq('user_id', user.id)
            .order('date');
        return {'type': 'photos', 'data': data};

      default:
        return {};
    }
  }

  // Обновление настроек пользователя
  static Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('users').update(settings).eq('id', user.id);
  }

  // Смена пароля
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Проверяем текущий пароль через повторную аутентификацию
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Меняем пароль
      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      return {
        'success': true,
        'message': 'Пароль успешно изменен',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Удаление аккаунта
  static Future<void> deleteAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Удаляем все фото из Storage
    final photos =
        await supabase.storage.from('progress-photos').list(path: user.id);

    if (photos.isNotEmpty) {
      await supabase.storage
          .from('progress-photos')
          .remove(photos.map((p) => '${user.id}/${p.name}').toList());
    }

    // Удаляем пользователя (каскадно удалятся все записи в БД)
    await supabase.rpc('delete_user_account');

    // Выходим из аккаунта
    await supabase.auth.signOut();
  }

// Выход из системы
  static Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      debugPrint('✅ Signed out from Supabase');
      // НЕ удаляем локальные данные
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }

  // Проверка статуса подтверждения email
  static bool isEmailConfirmed() {
    final user = supabase.auth.currentUser;
    return user != null && user.emailConfirmedAt != null;
  }

  // Получение текущего пользователя
  static User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Преобразование сообщений об ошибках в понятные для пользователя
  static String _getFriendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains('Invalid login credentials')) {
      return 'Неверный email или пароль';
    }
    if (errorMessage.contains('Email not confirmed')) {
      return 'Email не подтвержден. Проверьте почту и перейдите по ссылке.';
    }
    if (errorMessage.contains('User already registered')) {
      return 'Пользователь с таким email уже зарегистрирован';
    }
    if (errorMessage.contains('Password should be at least 6 characters')) {
      return 'Пароль должен содержать не менее 6 символов';
    }
    return errorMessage;
  }
}

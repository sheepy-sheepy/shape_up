import 'dart:math';

class CalculateNutrition {
  double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    if (gender == 'Мужской') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double getActivityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'Сидячий образ жизни':
        return 1.2;
      case 'Тренировки 1-3 раза в неделю':
        return 1.375;
      case 'Тренировки 3-5 раз в неделю':
        return 1.55;
      case 'Тренировки 6-7 раз в неделю':
        return 1.725;
      case 'Профессиональный спорт или физическая работа':
        return 1.9;
      default:
        return 1.2;
    }
  }

  double calculateDCI({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );

    final activityMultiplier = getActivityMultiplier(activityLevel);
    return bmr * activityMultiplier;
  }

  double calculateCalorieNorm({
    required double dci,
    required String goal,
    int? deficit,
    int? surplus,
  }) {
    switch (goal) {
      case 'Похудение':
        return dci - (deficit ?? 300);
      case 'Набор массы':
        return dci + (surplus ?? 500);
      case 'Поддержание':
      default:
        return dci;
    }
  }

  Map<String, double> calculateMacros({
    required double calories,
    required String goal,
  }) {
    double proteinPercent, fatPercent, carbPercent;

    switch (goal) {
      case 'Похудение':
        proteinPercent = 0.40;
        fatPercent = 0.25;
        carbPercent = 0.35;
        break;
      case 'Поддержание':
        proteinPercent = 0.25;
        fatPercent = 0.25;
        carbPercent = 0.50;
        break;
      case 'Набор массы':
        proteinPercent = 0.35;
        fatPercent = 0.20;
        carbPercent = 0.45;
        break;
      default:
        proteinPercent = 0.25;
        fatPercent = 0.25;
        carbPercent = 0.50;
    }

    return {
      'proteins': (calories * proteinPercent) / 4,
      'fats': (calories * fatPercent) / 9,
      'carbs': (calories * carbPercent) / 4,
    };
  }

  double calculateWaterNorm({
    required double weight,
    required String gender,
    required String activityLevel,
  }) {
    double baseMultiplier = gender == 'Мужской' ? 35.0 : 31.0;

    double activityMultiplier;
    switch (activityLevel) {
      case 'Сидячий образ жизни':
        activityMultiplier = 1.0;
        break;
      case 'Тренировки 1-3 раза в неделю':
        activityMultiplier = 1.2;
        break;
      case 'Тренировки 3-5 раз в неделю':
        activityMultiplier = 1.4;
        break;
      case 'Тренировки 6-7 раз в неделю':
        activityMultiplier = 1.6;
        break;
      case 'Профессиональный спорт или физическая работа':
        activityMultiplier = 1.8;
        break;
      default:
        activityMultiplier = 1.0;
    }

    return weight * baseMultiplier * activityMultiplier;
  }

  double calculateBodyFatPercentage({
    required double waist,
    required double neck,
    required double height,
    required String gender,
    double? hip,
  }) {
    if (gender == 'Мужской') {
      return 495 /
              (1.0324 -
                  0.19077 * (log(waist - neck) / ln10) +
                  0.15456 * (log(height) / ln10)) -
          450;
    } else {
      if (hip == null) return 0;
      return 495 /
              (1.29579 -
                  (0.35004 * (log(waist + hip - neck) / ln10)) +
                  (0.22100 * (log(height) / ln10))) -
          450;
    }
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

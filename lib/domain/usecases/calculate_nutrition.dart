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
      'proteins': (calories * proteinPercent) / 4, // 4 kcal per gram
      'fats': (calories * fatPercent) / 9, // 9 kcal per gram
      'carbs': (calories * carbPercent) / 4, // 4 kcal per gram
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
      // % жира = 86,010 x log10(waist - neck) - 70,041 x log10(height) + 36,76
      return 86.010 * log((waist - neck) / ln10) - 70.041 * log(height / ln10) + 36.76;
    } else {
      // % жира = 163,205 x log10(waist + hip - neck) - 97,684 x log10(height) - 78,387
      if (hip == null) return 0;
      return 163.205 * log((waist + hip - neck) / ln10) - 97.684 * log(height / ln10) - 78.387;
    }
  }
}
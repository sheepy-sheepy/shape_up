// lib/presentation/pages/main/main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:shape_up/presentation/pages/analytics/analytics_page.dart';
import 'package:shape_up/presentation/pages/diary/diary_page.dart';
import 'package:shape_up/presentation/pages/food/food_page.dart';
import 'package:shape_up/presentation/pages/photo/photo_page.dart';
import 'package:shape_up/presentation/pages/settings/settings_page.dart';
import 'package:shape_up/presentation/pages/body/body_params_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 2; // Default to Diary page

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BodyParamsPage(),
      const PhotoPage(),
      const DiaryPage(),
      const FoodPage(),
      const AnalyticsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Блокируем кнопку "назад" на всех экранах main_page
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle()),
          automaticallyImplyLeading: false, // Убираем стрелку назад
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new),
              label: 'Параметры',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera),
              label: 'Фото',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Дневник',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              label: 'Продукты',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Аналитика',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Параметры тела';
      case 1:
        return 'Фото';
      case 2:
        return 'Дневник питания';
      case 3:
        return 'Мои продукты';
      case 4:
        return 'Аналитика';
      default:
        return '';
    }
  }
}

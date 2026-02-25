// lib/presentation/pages/analytics/analytics_page.dart
import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedType = 'weight';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Аналитика',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Выбор типа аналитики
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Тип аналитики',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'weight', child: Text('Вес')),
                DropdownMenuItem(value: 'bodyFat', child: Text('% жира')),
                DropdownMenuItem(value: 'measurements', child: Text('Обхваты')),
                DropdownMenuItem(value: 'photos', child: Text('Фото до/после')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Заглушка для графика
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Здесь будет график'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Информация в зависимости от выбранного типа
            if (_selectedType == 'bodyFat') ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'О проценте жира',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Процент жира в организме - это доля жировой ткани от общей массы тела. '
                        'Здоровые показатели: для мужчин 10-20%, для женщин 18-28%.'
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
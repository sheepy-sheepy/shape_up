// lib/presentation/widgets/water_tracker.dart
import 'package:flutter/material.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  int _waterConsumed = 1500;
  final int _waterNorm = 2500;
  final TextEditingController _waterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final progress = _waterConsumed / _waterNorm;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вода',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.blue.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '$_waterConsumed мл / $_waterNorm мл',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waterController,
                    decoration: const InputDecoration(
                      labelText: 'мл воды',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: _removeWater,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addWater,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addWater() {
    final ml = int.tryParse(_waterController.text) ?? 0;
    if (ml > 0) {
      setState(() {
        _waterConsumed = (_waterConsumed + ml).clamp(0, _waterNorm * 2);
      });
      _waterController.clear();
    }
  }

  void _removeWater() {
    final ml = int.tryParse(_waterController.text) ?? 0;
    if (ml > 0) {
      setState(() {
        _waterConsumed = (_waterConsumed - ml).clamp(0, _waterConsumed);
      });
      _waterController.clear();
    }
  }

  @override
  void dispose() {
    _waterController.dispose();
    super.dispose();
  }
}
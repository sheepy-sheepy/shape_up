import 'package:flutter/material.dart';

class WaterTracker extends StatefulWidget {
  final int waterNorm;
  final int waterConsumed;
  final Function(int) onWaterAdded;

  const WaterTracker({
    super.key,
    required this.waterNorm,
    required this.waterConsumed,
    required this.onWaterAdded,
  });

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  final TextEditingController _waterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final progress = widget.waterConsumed / widget.waterNorm;
    final remaining = widget.waterNorm - widget.waterConsumed;

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
            
            // Прогресс бар
            Stack(
              children: [
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 20,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${widget.waterConsumed} мл / ${widget.waterNorm} мл',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Остаток
            if (remaining > 0)
              Text(
                'Осталось: $remaining мл',
                style: const TextStyle(color: Colors.blue),
              )
            else
              const Text(
                'Норма выполнена!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            
            const SizedBox(height: 16),
            
            // Поле ввода
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: _removeWater,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: _addWater,
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
    final ml = int.tryParse(_waterController.text);
    if (ml != null && ml > 0) {
      widget.onWaterAdded(ml);
      _waterController.clear();
    }
  }

  void _removeWater() {
    final ml = int.tryParse(_waterController.text);
    if (ml != null && ml > 0) {
      widget.onWaterAdded(-ml);
      _waterController.clear();
    }
  }

  @override
  void dispose() {
    _waterController.dispose();
    super.dispose();
  }
}
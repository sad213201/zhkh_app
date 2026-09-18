import 'package:flutter/material.dart';

import '../models/meter.dart';
import 'scan_meter_screen.dart';

class MeterDetailScreen extends StatelessWidget {
  final Meter meter;

  const MeterDetailScreen({super.key, required this.meter});

  @override
  Widget build(BuildContext context) {
    final difference = meter.differenceWithPrevious;
    final cost = meter.lastPeriodCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(meter.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Сканировать счётчик',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanMeterScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Основная информация
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Серийный номер: ${meter.serialNumber}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Текущие показания: ${meter.currentReading} ${meter.unit}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Тариф: ${meter.tariff} ₽ / ${meter.unit}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Разница и стоимость
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Расход за последний месяц:'),
                      Text(
                        '${difference.toStringAsFixed(1)} ${meter.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Стоимость:'),
                      Text(
                        '${cost.toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'История показаний',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Хронологический список (от новых к старым)
          ...meter.history.reversed.map((reading) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, size: 20),
                title: Text(reading.month),
                subtitle: Text(
                  '${reading.date.day}.${reading.date.month}.${reading.date.year}',
                ),
                trailing: Text(
                  '${reading.value} ${meter.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

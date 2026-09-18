import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/meter.dart';
import '../screens/meter_detail_screen.dart';

class MeterCard extends StatelessWidget {
  final Meter meter;

  const MeterCard({super.key, required this.meter});

  IconData _getIcon(MeterType type) {
    switch (type) {
      case MeterType.water:
        return Icons.water_drop;
      case MeterType.electricity:
        return Icons.bolt;
      case MeterType.gas:
        return Icons.local_fire_department;
      default:
        return Icons.speed;
    }
  }

  Color _getColor(MeterType type) {
    switch (type) {
      case MeterType.water:
        return Colors.blue;
      case MeterType.electricity:
        return Colors.amber.shade700;
      case MeterType.gas:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(meter.type);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MeterDetailScreen(meter: meter)),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(_getIcon(meter.type), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meter.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '№ ${meter.serialNumber}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${meter.currentReading} ${meter.unit}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'График расхода по месяцам:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx >= 0 && idx < meter.history.length) {
                              return Text(
                                meter.history[idx].month,
                                style: const TextStyle(fontSize: 11),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: meter.history.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.value);
                        }).toList(),
                        isCurved: true,
                        color: color,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

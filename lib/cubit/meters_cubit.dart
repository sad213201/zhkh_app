import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/meter.dart';
import '../services/database_service.dart';
import 'meters_state.dart';

class MetersCubit extends Cubit<MetersState> {
  final DatabaseService databaseService;

  MetersCubit({required this.databaseService})
    : super(const MetersState(selectedFilter: MeterType.all, allMeters: []));

  Future<void> loadMeters() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final rows = await databaseService.getAllMeters();

      final meters = <Meter>[];

      for (final row in rows) {
        final meterId = row['id'].toString();

        final readingRows = await databaseService.getReadings(meterId);

        final history = readingRows.map((reading) {
          return MonthlyReading(
            month: reading['month'].toString(),
            value: (reading['value'] as num).toDouble(),
            date: DateTime.parse(reading['date'].toString()),
          );
        }).toList();

        /*
         * Если пользователь добавил показание после
         * последнего серверного показания, оно становится
         * фактически последним показанием прибора.
         *
         * Поэтому отображаем последнее значение истории,
         * если история существует.
         */
        final currentReading = history.isNotEmpty
            ? history.last.value
            : (row['currentReading'] as num).toDouble();

        meters.add(
          Meter(
            id: meterId,
            title: row['title'].toString(),
            serialNumber: row['serialNumber'].toString(),
            type: _parseMeterType(row['type'].toString()),
            currentReading: currentReading,
            unit: row['unit'].toString(),
            tariff: (row['tariff'] as num?)?.toDouble() ?? 0.0,
            history: history,
          ),
        );
      }

      emit(
        state.copyWith(allMeters: meters, isLoading: false, clearError: true),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Не удалось загрузить данные: $e',
        ),
      );
    }
  }

  void setFilter(MeterType filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  MeterType _parseMeterType(String value) {
    switch (value) {
      case 'water':
        return MeterType.water;

      case 'gas':
        return MeterType.gas;

      case 'electricity':
        return MeterType.electricity;

      default:
        return MeterType.all;
    }
  }
}

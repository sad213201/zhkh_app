import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/meter.dart';
import 'meters_state.dart';

class MetersCubit extends Cubit<MetersState> {
  MetersCubit()
    : super(
        MetersState(selectedFilter: MeterType.all, allMeters: _initialData),
      );

  void setFilter(MeterType filter) {
    emit(MetersState(selectedFilter: filter, allMeters: state.allMeters));
  }

  static final List<Meter> _initialData = [
    Meter(
      id: '1',
      title: 'Холодная вода',
      serialNumber: 'СХВ-048291',
      type: MeterType.water,
      currentReading: 142.5,
      unit: 'м³',
      tariff: 25.40,
      history: [
        MonthlyReading(month: 'Янв', value: 135.2, date: DateTime(2026, 1, 15)),
        MonthlyReading(month: 'Фев', value: 137.8, date: DateTime(2026, 2, 15)),
        MonthlyReading(month: 'Мар', value: 140.1, date: DateTime(2026, 3, 15)),
        MonthlyReading(month: 'Апр', value: 142.5, date: DateTime(2026, 4, 15)),
      ],
    ),
    Meter(
      id: '2',
      title: 'Горячая вода',
      serialNumber: 'СГВ-991204',
      type: MeterType.water,
      currentReading: 68.3,
      unit: 'м³',
      tariff: 148.50,
      history: [
        MonthlyReading(month: 'Янв', value: 62.1, date: DateTime(2026, 1, 15)),
        MonthlyReading(month: 'Фев', value: 64.5, date: DateTime(2026, 2, 15)),
        MonthlyReading(month: 'Мар', value: 66.8, date: DateTime(2026, 3, 15)),
        MonthlyReading(month: 'Апр', value: 68.3, date: DateTime(2026, 4, 15)),
      ],
    ),
    Meter(
      id: '3',
      title: 'Электроэнергия',
      serialNumber: 'МЕРКУРИЙ-201',
      type: MeterType.electricity,
      currentReading: 1240.0,
      unit: 'кВт·ч',
      tariff: 5.20,
      history: [
        MonthlyReading(month: 'Янв', value: 1080, date: DateTime(2026, 1, 15)),
        MonthlyReading(month: 'Фев', value: 1135, date: DateTime(2026, 2, 15)),
        MonthlyReading(month: 'Мар', value: 1190, date: DateTime(2026, 3, 15)),
        MonthlyReading(month: 'Апр', value: 1240, date: DateTime(2026, 4, 15)),
      ],
    ),
    Meter(
      id: '4',
      title: 'Природный газ',
      serialNumber: 'ВК-G4-1029',
      type: MeterType.gas,
      currentReading: 310.8,
      unit: 'м³',
      tariff: 7.15,
      history: [
        MonthlyReading(month: 'Янв', value: 286.0, date: DateTime(2026, 1, 15)),
        MonthlyReading(month: 'Фев', value: 295.5, date: DateTime(2026, 2, 15)),
        MonthlyReading(month: 'Мар', value: 304.2, date: DateTime(2026, 3, 15)),
        MonthlyReading(month: 'Апр', value: 310.8, date: DateTime(2026, 4, 15)),
      ],
    ),
  ];
}

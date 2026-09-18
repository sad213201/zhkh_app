import 'package:equatable/equatable.dart';

import '../models/meter.dart';

class MetersState extends Equatable {
  final MeterType selectedFilter;
  final List<Meter> allMeters;

  const MetersState({required this.selectedFilter, required this.allMeters});

  List<Meter> get filteredMeters {
    if (selectedFilter == MeterType.all) return allMeters;
    return allMeters.where((m) => m.type == selectedFilter).toList();
  }

  @override
  List<Object?> get props => [selectedFilter, allMeters];
}

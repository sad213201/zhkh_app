import 'package:equatable/equatable.dart';

import '../models/meter.dart';

class MetersState extends Equatable {
  final MeterType selectedFilter;
  final List<Meter> allMeters;
  final bool isLoading;
  final String? error;

  const MetersState({
    required this.selectedFilter,
    required this.allMeters,
    this.isLoading = false,
    this.error,
  });

  List<Meter> get filteredMeters {
    if (selectedFilter == MeterType.all) {
      return allMeters;
    }

    return allMeters.where((meter) => meter.type == selectedFilter).toList();
  }

  MetersState copyWith({
    MeterType? selectedFilter,
    List<Meter>? allMeters,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MetersState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allMeters: allMeters ?? this.allMeters,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [selectedFilter, allMeters, isLoading, error];
}

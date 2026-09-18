import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/meters_cubit.dart';
import '../cubit/meters_state.dart';
import '../models/meter.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetersCubit, MetersState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildChip(context, 'Все', MeterType.all, state.selectedFilter),
              _buildChip(
                context,
                'Вода',
                MeterType.water,
                state.selectedFilter,
              ),
              _buildChip(
                context,
                'Электричество',
                MeterType.electricity,
                state.selectedFilter,
              ),
              _buildChip(context, 'Газ', MeterType.gas, state.selectedFilter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    MeterType type,
    MeterType current,
  ) {
    final isSelected = type == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          context.read<MetersCubit>().setFilter(type);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/meters_cubit.dart';
import '../cubit/meters_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/meter_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Приборы учета ЖКХ'), centerTitle: true),
      body: Column(
        children: [
          const FilterBar(),
          Expanded(
            child: BlocBuilder<MetersCubit, MetersState>(
              builder: (context, state) {
                final meters = state.filteredMeters;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: meters.length,
                  itemBuilder: (context, index) {
                    return MeterCard(meter: meters[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

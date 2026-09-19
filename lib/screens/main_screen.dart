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
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null && state.allMeters.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 16),
                          Text(state.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<MetersCubit>().loadMeters();
                            },
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final meters = state.filteredMeters;

                if (meters.isEmpty) {
                  return const Center(child: Text('Нет подключенных приборов'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<MetersCubit>().loadMeters();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: meters.length,
                    itemBuilder: (context, index) {
                      return MeterCard(meter: meters[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

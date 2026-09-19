import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/meters_cubit.dart';
import 'screens/main_screen.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';
import 'services/realm_service.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация вспомогательного хранилища тарифов.
  await RealmService.init();

  final databaseService = DatabaseService();
  final apiService = ApiService();

  final syncService = SyncService(
    apiService: apiService,
    databaseService: databaseService,
  );

  // REST-синхронизация выполняется ПРИ КАЖДОМ ЗАПУСКЕ.
  //
  // Если интернет/API недоступен, приложение не закрывается.
  // В этом случае будут использованы данные, которые уже есть в SQLite.
  try {
    await syncService.sync();
  } catch (e) {
    debugPrint('Ошибка REST-синхронизации: $e');
  }

  runApp(ZhkhApp(databaseService: databaseService));
}

class ZhkhApp extends StatelessWidget {
  final DatabaseService databaseService;

  const ZhkhApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Учет ЖКХ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) =>
            MetersCubit(databaseService: databaseService)..loadMeters(),
        child: const MainScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/meters_cubit.dart';
import 'screens/main_screen.dart';
import 'services/database_service.dart';
import 'services/realm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RealmService.init();
  await DatabaseService().syncWithRestApi();
  runApp(const ZhkhApp());
}

class ZhkhApp extends StatelessWidget {
  const ZhkhApp({super.key});

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
        create: (_) => MetersCubit(),
        child: const MainScreen(),
      ),
    );
  }
}

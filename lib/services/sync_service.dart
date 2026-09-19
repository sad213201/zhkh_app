import 'api_service.dart';
import 'database_service.dart';

class SyncService {
  final ApiService apiService;
  final DatabaseService databaseService;

  const SyncService({required this.apiService, required this.databaseService});

  Future<void> sync() async {
    final data = await apiService.fetchInitialData();

    await databaseService.syncFromRest(
      meters: data.meters,
      readings: data.readings,
    );
  }
}

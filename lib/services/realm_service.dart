import 'package:hive_flutter/hive_flutter.dart';

/// Вспомогательное хранилище тарифов (аналог Realm)
class RealmService {
  static const String boxName = 'tariffs';

  static Future<void> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(boxName);

    if (box.isEmpty) {
      // Тарифная сетка: id, базовая стоимость, норматив
      await box.putAll({
        'water_cold': {
          'id': 'water_cold',
          'resource': 'Холодная вода',
          'region': 'default',
          'price': 25.40,
          'norm': 6.0,
        },
        'water_hot': {
          'id': 'water_hot',
          'resource': 'Горячая вода',
          'region': 'default',
          'price': 148.50,
          'norm': 3.5,
        },
        'electricity': {
          'id': 'electricity',
          'resource': 'Электроэнергия',
          'region': 'default',
          'price': 5.20,
          'norm': 150.0,
        },
        'gas': {
          'id': 'gas',
          'resource': 'Газ',
          'region': 'default',
          'price': 7.15,
          'norm': 10.0,
        },
      });
    }
  }

  static double getPrice(String key) {
    final box = Hive.box(boxName);
    final data = box.get(key);
    if (data is Map) return (data['price'] as num?)?.toDouble() ?? 0.0;
    return 0.0;
  }
}

import 'package:hive_flutter/hive_flutter.dart';

class TariffModel {
  final String id;
  final String region;
  final String resourceType; // "water", "electricity", "gas"
  final double baseCost; // стоимость за куб/кВт
  final double norm; // норматив

  TariffModel({
    required this.id,
    required this.region,
    required this.resourceType,
    required this.baseCost,
    required this.norm,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'region': region,
    'resourceType': resourceType,
    'baseCost': baseCost,
    'norm': norm,
  };

  factory TariffModel.fromMap(Map<dynamic, dynamic> map) => TariffModel(
    id: map['id'] as String,
    region: map['region'] as String,
    resourceType: map['resourceType'] as String,
    baseCost: (map['baseCost'] as num).toDouble(),
    norm: (map['norm'] as num).toDouble(),
  );
}

class RealmService {
  static const String _boxName = 'tariffsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    var box = await Hive.openBox(_boxName);

    if (box.isEmpty) {
      List<TariffModel> initialTariffs = [
        TariffModel(
          id: '1',
          region: 'Москва',
          resourceType: 'electricity',
          baseCost: 6.43,
          norm: 150,
        ),
        TariffModel(
          id: '2',
          region: 'Москва',
          resourceType: 'water',
          baseCost: 50.20,
          norm: 5,
        ),
        TariffModel(
          id: '3',
          region: 'СПб',
          resourceType: 'electricity',
          baseCost: 5.70,
          norm: 140,
        ),
      ];

      for (var tariff in initialTariffs) {
        await box.put(tariff.id, tariff.toMap());
      }
    }
  }

  static List<TariffModel> getTariffsByRegion(String region) {
    var box = Hive.box(_boxName);
    return box.values
        .map((e) => TariffModel.fromMap(e as Map<dynamic, dynamic>))
        .where((tariff) => tariff.region == region)
        .toList();
  }
}

import 'package:dio/dio.dart';

class ApiMeter {
  final String id;
  final String title;
  final String serialNumber;
  final String type;
  final double currentReading;
  final String unit;
  final double tariff;

  const ApiMeter({
    required this.id,
    required this.title,
    required this.serialNumber,
    required this.type,
    required this.currentReading,
    required this.unit,
    required this.tariff,
  });

  factory ApiMeter.fromJson(Map<String, dynamic> json) {
    return ApiMeter(
      id: json['id'].toString(),
      title: json['title'].toString(),
      serialNumber: json['serialNumber'].toString(),
      type: json['type'].toString(),
      currentReading: (json['currentReading'] as num).toDouble(),
      unit: json['unit'].toString(),
      tariff: (json['tariff'] as num).toDouble(),
    );
  }
}

class ApiReading {
  final String meterId;
  final String month;
  final double value;
  final DateTime date;

  const ApiReading({
    required this.meterId,
    required this.month,
    required this.value,
    required this.date,
  });

  factory ApiReading.fromJson(Map<String, dynamic> json) {
    return ApiReading(
      meterId: json['meterId'].toString(),
      month: json['month'].toString(),
      value: (json['value'] as num).toDouble(),
      date: DateTime.parse(json['date'].toString()),
    );
  }
}

class ApiService {
  /*
   * ============================================================
   * ВАЖНО:
   * сюда после создания Postman Mock Server нужно вставить
   * адрес своего mock-сервера.
   *
   * Например:
   *
   * https://12345678.mock.pstmn.io
   *
   * НЕ добавляй сюда /meters.
   * Endpoint /meters добавляется ниже в GET.
   * ============================================================
   */
  static const String baseUrl = 'http://10.0.2.2:4500';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<({List<ApiMeter> meters, List<ApiReading> readings})>
  fetchInitialData() async {
    final response = await _dio.get('/meters');

    if (response.statusCode != 200) {
      throw Exception('REST API вернул код ${response.statusCode}');
    }

    if (response.data is! Map) {
      throw Exception('REST API вернул некорректный JSON');
    }

    final data = Map<String, dynamic>.from(response.data as Map);

    final rawMeters = data['meters'];

    final rawReadings = data['readings'];

    if (rawMeters is! List) {
      throw Exception('В ответе REST API отсутствует массив meters');
    }

    if (rawReadings is! List) {
      throw Exception('В ответе REST API отсутствует массив readings');
    }

    final meters = rawMeters
        .map(
          (item) => ApiMeter.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    final readings = rawReadings
        .map(
          (item) => ApiReading.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    return (meters: meters, readings: readings);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'zhkh.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Изначально пустая БД
        await db.execute('''
          CREATE TABLE meters (
            id TEXT PRIMARY KEY,
            title TEXT,
            serialNumber TEXT,
            type TEXT,
            currentReading REAL,
            unit TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meterId TEXT,
            month TEXT,
            value REAL,
            date TEXT,
            FOREIGN KEY (meterId) REFERENCES meters (id)
          )
        ''');
      },
    );
  }

  /// Заполнение/обновление начальными данными через mock REST при старте.
  /// Данные пользователя не затираются.
  Future<void> syncWithRestApi() async {
    final db = await database;

    final existing = await db.query('meters');
    if (existing.isNotEmpty) {
      // Уже есть данные (в т.ч. добавленные пользователем) — не трогаем
      return;
    }

    // Mock REST — начальные данные
    final meters = [
      {
        'id': '1',
        'title': 'Холодная вода',
        'serialNumber': 'СХВ-048291',
        'type': 'water',
        'currentReading': 142.5,
        'unit': 'м³',
      },
      {
        'id': '2',
        'title': 'Горячая вода',
        'serialNumber': 'СГВ-991204',
        'type': 'water',
        'currentReading': 68.3,
        'unit': 'м³',
      },
      {
        'id': '3',
        'title': 'Электроэнергия',
        'serialNumber': 'МЕРКУРИЙ-201',
        'type': 'electricity',
        'currentReading': 1240.0,
        'unit': 'кВт·ч',
      },
      {
        'id': '4',
        'title': 'Природный газ',
        'serialNumber': 'ВК-G4-1029',
        'type': 'gas',
        'currentReading': 310.8,
        'unit': 'м³',
      },
    ];

    final readings = [
      // Холодная вода
      {'meterId': '1', 'month': 'Янв', 'value': 135.2, 'date': '2026-01-15'},
      {'meterId': '1', 'month': 'Фев', 'value': 137.8, 'date': '2026-02-15'},
      {'meterId': '1', 'month': 'Мар', 'value': 140.1, 'date': '2026-03-15'},
      {'meterId': '1', 'month': 'Апр', 'value': 142.5, 'date': '2026-04-15'},
      // Горячая вода
      {'meterId': '2', 'month': 'Янв', 'value': 62.1, 'date': '2026-01-15'},
      {'meterId': '2', 'month': 'Фев', 'value': 64.5, 'date': '2026-02-15'},
      {'meterId': '2', 'month': 'Мар', 'value': 66.8, 'date': '2026-03-15'},
      {'meterId': '2', 'month': 'Апр', 'value': 68.3, 'date': '2026-04-15'},
      // Электричество
      {'meterId': '3', 'month': 'Янв', 'value': 1080.0, 'date': '2026-01-15'},
      {'meterId': '3', 'month': 'Фев', 'value': 1135.0, 'date': '2026-02-15'},
      {'meterId': '3', 'month': 'Мар', 'value': 1190.0, 'date': '2026-03-15'},
      {'meterId': '3', 'month': 'Апр', 'value': 1240.0, 'date': '2026-04-15'},
      // Газ
      {'meterId': '4', 'month': 'Янв', 'value': 286.0, 'date': '2026-01-15'},
      {'meterId': '4', 'month': 'Фев', 'value': 295.5, 'date': '2026-02-15'},
      {'meterId': '4', 'month': 'Мар', 'value': 304.2, 'date': '2026-03-15'},
      {'meterId': '4', 'month': 'Апр', 'value': 310.8, 'date': '2026-04-15'},
    ];

    for (final m in meters) {
      await db.insert('meters', m, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final r in readings) {
      await db.insert(
        'readings',
        r,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllMeters() async {
    final db = await database;
    return db.query('meters');
  }

  Future<List<Map<String, dynamic>>> getReadings(String meterId) async {
    final db = await database;
    return db.query(
      'readings',
      where: 'meterId = ?',
      whereArgs: [meterId],
      orderBy: 'date ASC',
    );
  }
}

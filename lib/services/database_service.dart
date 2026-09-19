import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'api_service.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await _initDB();

    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'zhkh.db');

    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meters (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            serialNumber TEXT NOT NULL,
            type TEXT NOT NULL,
            currentReading REAL NOT NULL,
            unit TEXT NOT NULL,
            tariff REAL NOT NULL DEFAULT 0,
            isUserCreated INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meterId TEXT NOT NULL,
            month TEXT NOT NULL,
            value REAL NOT NULL,
            date TEXT NOT NULL,
            isUserCreated INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (meterId)
              REFERENCES meters (id)
              ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE meters
            ADD COLUMN tariff REAL NOT NULL DEFAULT 0
          ''');

          await db.execute('''
            ALTER TABLE meters
            ADD COLUMN isUserCreated INTEGER NOT NULL DEFAULT 0
          ''');

          await db.execute('''
            ALTER TABLE readings
            ADD COLUMN isUserCreated INTEGER NOT NULL DEFAULT 0
          ''');
        }
      },
    );
  }

  // ============================================================
  // ПОЛНЫЙ СБРОС БАЗЫ (Если застряли старые дубли)
  // ============================================================

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('readings');
    await db.delete('meters');
  }

  // ============================================================
  // REST → SQLite
  // ============================================================

  Future<void> syncFromRest({
    required List<ApiMeter> meters,
    required List<ApiReading> readings,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      /*
       * 1. Синхронизируем приборы учёта
       */
      for (final meter in meters) {
        final existing = await txn.query(
          'meters',
          where: 'id = ?',
          whereArgs: [meter.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          await txn.insert('meters', {
            'id': meter.id,
            'title': meter.title,
            'serialNumber': meter.serialNumber,
            'type': meter.type,
            'currentReading': meter.currentReading,
            'unit': meter.unit,
            'tariff': meter.tariff,
            'isUserCreated': 0,
          });
        } else {
          final localMeter = existing.first;
          final isUserCreated = (localMeter['isUserCreated'] as int?) ?? 0;

          // Обновляем только серверные счетчики
          if (isUserCreated == 0) {
            await txn.update(
              'meters',
              {
                'title': meter.title,
                'serialNumber': meter.serialNumber,
                'type': meter.type,
                'currentReading': meter.currentReading,
                'unit': meter.unit,
                'tariff': meter.tariff,
              },
              where: 'id = ?',
              whereArgs: [meter.id],
            );
          }
        }
      }

      /*
       * 2. Синхронизируем историю показаний
       */
      for (final reading in readings) {
        final dateStr = reading.date.toIso8601String().split('T').first;

        final existing = await txn.query(
          'readings',
          where: 'meterId = ? AND date LIKE ?',
          whereArgs: [reading.meterId, '$dateStr%'],
          limit: 1,
        );

        if (existing.isEmpty) {
          await txn.insert('readings', {
            'meterId': reading.meterId,
            'month': reading.month,
            'value': reading.value,
            'date': reading.date.toIso8601String(),
            'isUserCreated': 0,
          });
        } else {
          final localReading = existing.first;
          final isUserCreated = (localReading['isUserCreated'] as int?) ?? 0;

          if (isUserCreated == 0) {
            await txn.update(
              'readings',
              {'month': reading.month, 'value': reading.value},
              where: 'id = ?',
              whereArgs: [localReading['id']],
            );
          }
        }
      }
    });
  }

  // ============================================================
  // ЧТЕНИЕ ИЗ SQLITE
  // ============================================================

  Future<List<Map<String, dynamic>>> getAllMeters() async {
    final db = await database;
    return db.query('meters', orderBy: 'id ASC');
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

  // ============================================================
  // ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЬСКОГО ПОКАЗАНИЯ
  // ============================================================

  Future<int> insertUserReading({
    required String meterId,
    required double value,
    DateTime? date,
  }) async {
    final db = await database;
    final readingDate = date ?? DateTime.now();

    final monthNames = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];

    final month = monthNames[readingDate.month - 1];

    return db.insert('readings', {
      'meterId': meterId,
      'month': month,
      'value': value,
      'date': readingDate.toIso8601String(),
      'isUserCreated': 1,
    });
  }

  // ============================================================
  // ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЬСКОГО ПРИБОРА
  // ============================================================

  Future<void> insertUserMeter({
    required String id,
    required String title,
    required String serialNumber,
    required String type,
    required double currentReading,
    required String unit,
    required double tariff,
  }) async {
    final db = await database;

    await db.insert('meters', {
      'id': id,
      'title': title,
      'serialNumber': serialNumber,
      'type': type,
      'currentReading': currentReading,
      'unit': unit,
      'tariff': tariff,
      'isUserCreated': 1,
    });
  }
}

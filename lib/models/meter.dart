enum MeterType { all, water, gas, electricity }

class MonthlyReading {
  final String month;
  final double value;
  final DateTime date;

  MonthlyReading({
    required this.month,
    required this.value,
    required this.date,
  });
}

class Meter {
  final String id;
  final String title;
  final String serialNumber;
  final MeterType type;
  final double currentReading;
  final String unit;
  final List<MonthlyReading> history;
  final double tariff;

  Meter({
    required this.id,
    required this.title,
    required this.serialNumber,
    required this.type,
    required this.currentReading,
    required this.unit,
    required this.history,
    required this.tariff,
  });

  double get differenceWithPrevious {
    if (history.length < 2) return 0;
    return history.last.value - history[history.length - 2].value;
  }

  double get lastPeriodCost => differenceWithPrevious * tariff;
}
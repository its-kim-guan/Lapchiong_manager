String formatCurrency(int value) {
  final sign = value < 0 ? '-' : '';
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final positionFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${sign}Rp ${buffer.toString()}';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day-$month-${date.year}';
}

int? firstIntValue(List<Map<String, Object?>> rows) {
  if (rows.isEmpty) {
    return null;
  }

  final firstRow = rows.first;
  if (firstRow.isEmpty) {
    return null;
  }

  final value = firstRow.values.first;
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value');
}

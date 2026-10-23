String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Wajib diisi';
  }
  return null;
}

String? positiveNumberValidator(String? value) {
  final number = int.tryParse(value ?? '');
  if (number == null || number <= 0) {
    return 'Masukkan angka > 0';
  }
  return null;
}

String? nonNegativeValidator(String? value) {
  final number = int.tryParse(value ?? '');
  if (number == null || number < 0) {
    return 'Masukkan angka >= 0';
  }
  return null;
}

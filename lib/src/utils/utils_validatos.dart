bool isNumeric(String s) {
  if (s.isEmpty) return false;
  final n = num.tryParse(s);
  return n == null ? false : true;
}

String isTextEmpty({String value, int length, String message}) {
  return value.isEmpty || value.length < length ? message : null;
}

String isNumberEmpty({String value, String message}) {
  final numberToConvert = value.replaceAll(RegExp('S/'), '');
  final number = double.parse(numberToConvert);
  return number == 0 ? message : null;
}

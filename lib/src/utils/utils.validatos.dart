bool isNumeric(String s) {
  if (s.isEmpty) return false;
  final n = num.tryParse(s);
  return n == null ? false : true;
}

String isTextEmpty({String value, int length, String message}) {
  return value.isEmpty || value.length < length ? message : null;
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
  String toStringDouble(int n) => toStringAsFixed(n);
}

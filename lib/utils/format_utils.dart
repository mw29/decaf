/// Shows decimals only when needed (e.g. 2.5 → "2.5mg", 20 → "20mg")
String formatMg(double value) {
  if (value == value.roundToDouble()) return '${value.toInt()}mg';
  return '${value.toStringAsFixed(1)}mg';
}

/// Plain numeric string for text field input (no "mg" suffix)
String formatMgValue(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

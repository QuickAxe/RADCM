String capitalize(String x) {
  if (x.isEmpty) return x;
  return "${x[0].toUpperCase()}${x.substring(1)}";
}

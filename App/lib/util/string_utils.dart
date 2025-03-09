String capitalize(String? x) {
  if (x == null) return "";
  return "${x[0].toUpperCase()}${x.substring(1)}";
}

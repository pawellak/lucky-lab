/// Formats bytes as uppercase hex, e.g. `[0x02, 0x15]` → `02 15`.
String toHex(List<int> bytes, {String separator = ' '}) => bytes
    .map((b) => (b & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase())
    .join(separator);

/// Appearance categories (the top 10 bits of AD type 0x19) from the
/// Bluetooth SIG "Assigned Numbers" document.
const appearanceCategories = <int, String>{
  0: 'Unknown',
  1: 'Phone',
  2: 'Computer',
  3: 'Watch',
  4: 'Clock',
  5: 'Display',
  6: 'Remote control',
  7: 'Eyeglasses',
  8: 'Tag',
  9: 'Keyring',
  10: 'Media player',
  11: 'Barcode scanner',
  12: 'Thermometer',
  13: 'Heart rate sensor',
  14: 'Blood pressure',
  15: 'Human interface device',
  16: 'Glucose meter',
  17: 'Running / walking sensor',
  18: 'Cycling',
};

/// `0x00C1 (Watch, subcategory 1)`: category in the top 10 bits,
/// subcategory in the low 6.
String describeAppearance(int appearance) {
  final hex = appearance.toRadixString(16).toUpperCase().padLeft(4, '0');
  final category =
      appearanceCategories[appearance >> 6] ?? 'category ${appearance >> 6}';
  final sub = appearance & 0x3F;
  return '0x$hex ($category${sub == 0 ? '' : ', subcategory $sub'})';
}

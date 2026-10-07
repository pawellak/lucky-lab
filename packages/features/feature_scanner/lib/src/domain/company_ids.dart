/// A few Bluetooth SIG company identifiers you meet often.
///
/// The full list (thousands of entries) is in the SIG's "Assigned Numbers"
/// document. These ids are the first two bytes (little-endian) of every
/// Manufacturer Specific Data AD structure.
const companyNames = <int, String>{
  0x0006: 'Microsoft',
  0x000D: 'Texas Instruments',
  0x004C: 'Apple',
  0x0059: 'Nordic Semiconductor',
  0x0075: 'Samsung',
  0x0087: 'Garmin',
  0x00E0: 'Google',
  0x0131: 'Cypress Semiconductor',
  0x0157: 'Huami (Amazfit)',
  0x0171: 'Amazon',
  0x02E5: 'Espressif',
  0x038F: 'Xiaomi',
  0x0499: 'Ruuvi Innovations',
  0xFFFF: 'Reserved for testing',
};

/// `Apple (0x004C)`, or just `0x1234` for ids not in [companyNames].
String describeCompany(int id) {
  final hex = '0x${id.toRadixString(16).padLeft(4, '0').toUpperCase()}';
  final name = companyNames[id];
  return name == null ? hex : '$name ($hex)';
}

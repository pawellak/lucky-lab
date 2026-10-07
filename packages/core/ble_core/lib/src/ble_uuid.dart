/// Helpers for Bluetooth UUIDs. `ble_core` always uses the lowercase
/// 128-bit form, e.g. `0000feaa-0000-1000-8000-00805f9b34fb`.
abstract final class BleUuid {
  /// The Bluetooth Base UUID's tail. A 16-bit UUID such as `FEAA` is
  /// shorthand for `0000FEAA-0000-1000-8000-00805F9B34FB`.
  static const _baseSuffix = '-0000-1000-8000-00805f9b34fb';

  /// Expands an assigned 16-bit UUID (e.g. `0xFEAA`) to its 128-bit form.
  static String from16(int uuid16) =>
      '0000${uuid16.toRadixString(16).padLeft(4, '0')}$_baseSuffix';

  /// The shortest readable form: `FEAA` for UUIDs built on the Base UUID,
  /// the full 128-bit string otherwise.
  static String short(String uuid128) {
    final uuid = uuid128.toLowerCase();
    if (uuid.startsWith('0000') && uuid.endsWith(_baseSuffix)) {
      return uuid.substring(4, 8).toUpperCase();
    }
    return uuid;
  }
}

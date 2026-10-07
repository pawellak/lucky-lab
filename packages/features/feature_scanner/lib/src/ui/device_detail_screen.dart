import 'package:ble_core/ble_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../domain/advertisement_payload.dart';
import '../domain/appearance.dart';
import '../domain/calibration.dart';
import '../domain/company_ids.dart';
import '../domain/packet_field.dart';
import '../domain/pdu_header.dart';
import '../domain/scanned_device.dart';
import '../state/calibration_controller.dart';
import '../state/scan_filter_controller.dart';
import 'calibration_panel.dart';
import 'packet_cheat_sheet.dart';
import 'pdu_header_view.dart';
import 'rssi_chart.dart';

/// Everything decoded from one device's advertisements, live.
class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(scannedDeviceProvider(deviceId));
    final calibration = ref.watch(
      calibrationsProvider.select((all) => all[deviceId]),
    );
    return Scaffold(
      appBar: AppBar(title: Text(device?.name ?? deviceId)),
      body: device == null
          ? const Center(child: Text('Device no longer in the scan.'))
          : _DeviceDetails(device: device, calibration: calibration),
    );
  }
}

class _DeviceDetails extends StatelessWidget {
  const _DeviceDetails({required this.device, required this.calibration});

  final ScannedDevice device;

  /// The user's own `P_1m` for this device, preferred over packet data.
  final RssiCalibration? calibration;

  @override
  Widget build(BuildContext context) {
    final ad = device.advertisement;
    final (referencePower, referenceSource) = switch (calibration) {
      final c? => (c.referencePower, 'your calibration'),
      null => (device.measuredPowerAt1m, 'device data'),
    };
    final distance = referencePower == null
        ? null
        : estimateDistanceMeters(
            rssi: device.rssi,
            measuredPowerAt1m: referencePower,
          );
    final fields = describePacket(
      device,
      isIos: defaultTargetPlatform == TargetPlatform.iOS,
    );
    List<PacketField> shownIn(String card) => [
      for (final field in fields)
        if (field.cards.contains(card)) field,
    ];
    PacketField field(int number) =>
        fields.firstWhere((field) => field.number == number);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PacketCheatSheet(fields: fields),
        _Section(
          title: DeviceCards.signal,
          badges: shownIn(DeviceCards.signal),
          children: [
            _Field('RSSI', formatDbm(device.rssi)),
            if (distance != null)
              _Field(
                'Distance (rough)',
                '≈ ${distance.toStringAsFixed(distance < 10 ? 1 : 0)} m\n'
                    'from $referenceSource: $referencePower dBm at 1 m',
              ),
            _Field(
              'Packets',
              '${device.packetCount} '
                  '(${device.packetsPerSecond.toStringAsFixed(1)}/s)',
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: RssiChart(samples: device.rssiHistory),
            ),
            const SizedBox(height: 8),
            CalibrationPanel(deviceId: device.id),
          ],
        ),
        for (final payload in device.payloads)
          _PayloadSection(
            payload,
            // iBeacon lives in manufacturer data, Eddystone in service data.
            badges: [field(payload is IBeaconPayload ? 11 : 10)],
          ),
        _Section(
          title: DeviceCards.pduHeader,
          badges: shownIn(DeviceCards.pduHeader),
          children: [PduHeaderView(fields: describePduHeader(device))],
        ),
        _Section(
          title: DeviceCards.deviceInfo,
          badges: shownIn(DeviceCards.deviceInfo),
          children: [
            // iOS never exposes AdvA; FBP gives CoreBluetooth's
            // peripheral.identifier, a UUID made up per phone.
            _Field(
              isMacAddress(device.id)
                  ? 'Address'
                  : 'iOS identifier (not the address)',
              device.id,
            ),
            _Field('Name', ad.localName ?? '—'),
            _Field('Connectable', ad.connectable ? 'yes' : 'no'),
            if (ad.txPowerLevel case final tx?)
              _Field('TX power', formatDbm(tx)),
            if (calibration case final calibration?)
              _Field(
                'Measured TX power',
                '${formatDbm(calibration.measuredTxPower)}\n'
                    '${_compareTxPower(calibration.measuredTxPower, ad.txPowerLevel)}',
              ),
            if (ad.appearance case final appearance?)
              _Field('Appearance', describeAppearance(appearance)),
          ],
        ),
        if (ad.serviceUuids.isNotEmpty || ad.serviceData.isNotEmpty)
          _UuidSection(ad, badges: shownIn(DeviceCards.uuids)),
        if (ad.manufacturerData.isNotEmpty || ad.serviceData.isNotEmpty)
          _Section(
            title: DeviceCards.payloadBytes,
            badges: shownIn(DeviceCards.payloadBytes),
            children: [
              // FBP hands us these values already cut out of the packet;
              // the raw AdvData bytes never reach Dart.
              Text(
                'Payload bytes as parsed by the OS. Flags and AD headers '
                '(length, type, company ID) are not shown.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              for (final MapEntry(:key, :value) in ad.manufacturerData.entries)
                _Field(
                  'Manufacturer ${describeCompany(key)}',
                  toHex(value),
                  monospace: true,
                ),
              for (final MapEntry(:key, :value) in ad.serviceData.entries)
                _Field(
                  _serviceLabel('Service data', key),
                  '$key\n${toHex(value)}',
                  monospace: true,
                ),
            ],
          ),
      ],
    );
  }

  /// How the calibrated TX power compares with what the device declares.
  static String _compareTxPower(int measured, int? declared) =>
      switch (declared) {
        null => 'from your calibration; the device declares none',
        final d when d == measured => 'matches the declared value',
        final d when d > measured =>
          '${d - measured} dB below the declared $d dBm',
        final d => '${measured - d} dB above the declared $d dBm',
      };

  /// `Service FEAA` for UUIDs on the Base UUID, `Service (custom 128-bit)`
  /// for vendor UUIDs, which have no short form.
  static String _serviceLabel(String prefix, String uuid128) {
    final short = BleUuid.short(uuid128);
    return short == uuid128 ? '$prefix (custom 128-bit)' : '$prefix $short';
  }
}

/// Each advertised UUID as the platform reported it: its size in the
/// packet, the short form and the full 128-bit form.
class _UuidSection extends StatelessWidget {
  const _UuidSection(this.ad, {required this.badges});

  final BleAdvertisement ad;
  final List<PacketField> badges;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: DeviceCards.uuids,
      badges: badges,
      children: [
        for (final uuid in ad.serviceUuids) _uuidField('Service', uuid),
        for (final uuid in ad.serviceData.keys)
          _uuidField('Service data', uuid),
      ],
    );
  }

  _Field _uuidField(String kind, String uuid128) {
    final size = switch (ad.uuidByteLengths[uuid128]) {
      final bytes? => '$bytes bytes (${bytes * 8}-bit)',
      null => 'size not reported',
    };
    final short = BleUuid.short(uuid128);
    return _Field(
      '$kind · $size',
      short == uuid128 ? uuid128 : '$short\n$uuid128',
      monospace: true,
    );
  }
}

class _PayloadSection extends StatelessWidget {
  const _PayloadSection(this.payload, {required this.badges});

  final AdvertisementPayload payload;
  final List<PacketField> badges;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: payload.label,
      badges: badges,
      children: switch (payload) {
        IBeaconPayload(
          :final proximityUuid,
          :final major,
          :final minor,
          :final measuredPower,
        ) =>
          [
            _Field('Proximity UUID', proximityUuid, monospace: true),
            _Field('Major', '$major'),
            _Field('Minor', '$minor'),
            _Field('Power at 1 m', formatDbm(measuredPower)),
          ],
        EddystoneUidPayload(
          :final namespace,
          :final instance,
          :final txPowerAt0m,
        ) =>
          [
            _Field('Namespace', namespace, monospace: true),
            _Field('Instance', instance, monospace: true),
            _Field('Power at 0 m', formatDbm(txPowerAt0m)),
          ],
        EddystoneUrlPayload(:final url, :final txPowerAt0m) => [
          _Field('URL', url),
          _Field('Power at 0 m', formatDbm(txPowerAt0m)),
        ],
        EddystoneTlmPayload(
          :final batteryMillivolts,
          :final temperatureCelsius,
          :final advertisingCount,
          :final uptime,
        ) =>
          [
            _Field(
              'Battery',
              batteryMillivolts == null
                  ? 'not reported'
                  : '$batteryMillivolts mV',
            ),
            _Field(
              'Temperature',
              temperatureCelsius == null
                  ? 'not reported'
                  : '${temperatureCelsius.toStringAsFixed(1)} °C',
            ),
            _Field('Packets sent', '$advertisingCount'),
            _Field('Uptime', _formatDuration(uptime)),
          ],
      },
    );
  }

  static String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    return [
      if (days > 0) '${days}d',
      if (days > 0 || hours > 0) '${hours}h',
      '${minutes}m',
    ].join(' ');
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
    this.badges = const [],
  });

  final String title;
  final List<Widget> children;

  /// Cheat sheet numbers of the packet parts this card shows.
  final List<PacketField> badges;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final field in badges)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: FieldNumberBadge(field),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, {this.monospace = false});

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SelectableText(
            value,
            style: monospace
                ? const TextStyle(fontFamily: 'monospace', fontSize: 13)
                : null,
          ),
        ],
      ),
    );
  }
}

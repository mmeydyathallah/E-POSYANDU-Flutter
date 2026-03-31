import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'activity_log_service.dart';
import 'app_settings_service.dart';

class BleService {
  // Singleton instance
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // ESP32 UUIDs from original Kotlin Project
  static const String serviceUuid = "12345678-1234-1234-1234-123456789abc";
  static const String dataCharacteristicUuid =
      "abcd1234-5678-1234-5678-abcdef012345";
  static const String commandCharacteristicUuid =
      "abcd1234-5678-1234-5678-abcdef012346";

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataChar;
  BluetoothCharacteristic? _commandChar;

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  Stream<BluetoothConnectionState> get connectionStateStream =>
      _connectedDevice?.connectionState ??
      Stream.value(BluetoothConnectionState.disconnected);

  String? lastData;

  // Stream for raw string data from ESP32
  final StreamController<String> _sensorDataController =
      StreamController<String>.broadcast();
  Stream<String> get sensorDataStream => _sensorDataController.stream;

  // Stream for scan results
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.onScanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan() async {
    // Check if Bluetooth is ON before scanning
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print("Bluetooth is OFF. Please turn it ON.");
      await ActivityLogService().log(
        'BLE',
        'Scan gagal: Bluetooth belum aktif.',
      );
      return;
    }
    final timeout =
        Duration(seconds: AppSettingsService().settings.scanTimeoutSeconds);
    await ActivityLogService().log('BLE', 'Memulai scan perangkat BLE.');
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await ActivityLogService().log('BLE', 'Scan BLE dihentikan.');
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    final name = device.advName.isEmpty ? 'Unknown Device' : device.advName;
    await ActivityLogService().log(
      'BLE',
      'Mencoba koneksi ke $name (${device.remoteId}).',
    );
    try {
      // Re-adding the required license parameter for your specific environment
      await device.connect(license: License.free);

      // Small delay for stability on some Android devices
      await Future.delayed(const Duration(milliseconds: 500));

      // Request higher MTU (though 15 bytes fits in default 23, it's good practice)
      try {
        await device.requestMtu(255);
      } catch (_) {}

      await _discoverServices();
      await ActivityLogService().log(
        'BLE',
        'Koneksi berhasil ke $name (${device.remoteId}).',
      );
    } catch (e) {
      print("Error connecting to device: $e");
      await ActivityLogService().log(
        'BLE',
        'Koneksi gagal ke ${device.remoteId}: $e',
      );
      rethrow;
    }
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    print("Discovering services for ${_connectedDevice!.remoteId}...");
    List<BluetoothService> services = await _connectedDevice!
        .discoverServices();
    print("Found ${services.length} services");

    for (BluetoothService service in services) {
      String sUuid = service.uuid.toString().toLowerCase();
      print("Checking service: $sUuid");

      if (sUuid == serviceUuid.toLowerCase()) {
        print("MATCH FOUND: Service $serviceUuid");
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          String cUuid = characteristic.uuid.toString().toLowerCase();
          print("  Checking characteristic: $cUuid");

          if (cUuid == dataCharacteristicUuid.toLowerCase()) {
            print("  MATCH FOUND: Data characteristic $dataCharacteristicUuid");
            _dataChar = characteristic;
            await _subscribeToData();
          } else if (cUuid == commandCharacteristicUuid.toLowerCase()) {
            print(
              "  MATCH FOUND: Command characteristic $commandCharacteristicUuid",
            );
            _commandChar = characteristic;
          }
        }
      }
    }
  }

  Future<void> _subscribeToData() async {
    if (_dataChar != null) {
      print("Subscribing to data notifications...");
      await _dataChar!.setNotifyValue(true);
      _dataChar!.onValueReceived.listen((value) {
        try {
          // Use utf8.decode and trim to remove potential null terminators or extra space
          String decodedString = utf8.decode(value).trim();
          // Clean any invisible characters (like null terminators \x00) that cause parsing issues
          String cleanString = decodedString.replaceAll(
            RegExp(r'[^0-9\.,\-]'),
            '',
          );
          print(
            "BLE Data Received: '$decodedString' -> Cleaned: '$cleanString'",
          );
          if (cleanString.isNotEmpty) {
            lastData = cleanString;
            _sensorDataController.add(cleanString);
          }
        } catch (e) {
          print("Error decoding BLE data: $e");
        }
      });
    }
  }

  Future<void> sendCommand(String cmd) async {
    if (_commandChar != null) {
      try {
        await _commandChar!.write(cmd.codeUnits);
        print("Command sent: $cmd");
        await ActivityLogService().log('BLE', 'Perintah dikirim: $cmd');
      } catch (e) {
        print("Error sending command: $e");
        await ActivityLogService().log('BLE', 'Gagal kirim perintah "$cmd": $e');
      }
    } else {
      print("Command characteristic not found!");
      await ActivityLogService().log(
        'BLE',
        'Gagal kirim perintah "$cmd": characteristic tidak ditemukan.',
      );
    }
  }

  void disconnect() {
    if (_connectedDevice != null) {
      final name = _connectedDevice!.advName.isEmpty
          ? 'Unknown Device'
          : _connectedDevice!.advName;
      ActivityLogService().log(
        'BLE',
        'Memutus koneksi dari $name (${_connectedDevice!.remoteId}).',
      );
    }
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _dataChar = null;
    _commandChar = null;
    lastData = null;
  }
}

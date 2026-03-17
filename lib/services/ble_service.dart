import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  // ESP32 UUIDs from original Kotlin Project
  static const String serviceUuid = "12345678-1234-1234-1234-123456789abc";
  static const String dataCharacteristicUuid = "abcd1234-5678-1234-5678-abcdef012345";
  static const String commandCharacteristicUuid = "abcd1234-5678-1234-5678-abcdef012346";

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataChar;
  BluetoothCharacteristic? _commandChar;

  // Stream for raw string data from ESP32
  final StreamController<String> _sensorDataController = StreamController<String>.broadcast();
  Stream<String> get sensorDataStream => _sensorDataController.stream;

  // Stream for scan results
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.onScanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Future<void> startScan() async {
    // Check if Bluetooth is ON before scanning
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      print("Bluetooth is OFF. Please turn it ON.");
      return;
    }
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;
    try {
      // Re-adding the required license parameter for your specific environment
      await device.connect(license: License.free);
      await _discoverServices();
    } catch (e) {
      print("Error connecting to device: $e");
      rethrow;
    }
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;
    
    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == dataCharacteristicUuid.toLowerCase()) {
            _dataChar = characteristic;
            await _subscribeToData();
          } else if (characteristic.uuid.toString().toLowerCase() == commandCharacteristicUuid.toLowerCase()) {
            _commandChar = characteristic;
          }
        }
      }
    }
  }

  Future<void> _subscribeToData() async {
    if (_dataChar != null) {
      await _dataChar!.setNotifyValue(true);
      _dataChar!.onValueReceived.listen((value) {
        String decodedString = String.fromCharCodes(value);
        _sensorDataController.add(decodedString);
      });
    }
  }

  void disconnect() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _dataChar = null;
    _commandChar = null;
  }
}

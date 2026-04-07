import 'package:flutter/foundation.dart';
import '../models/device_model.dart';

class AppDatabase extends ChangeNotifier {
  static final AppDatabase instance = AppDatabase._init();
  AppDatabase._init();

  final List<DeviceModel> _devices = [];

  List<DeviceModel> get devices => _devices;

  void addDeviceOrUpdate(DeviceModel device) {
    final index = _devices.indexWhere((d) => d.imei == device.imei);
    if (index >= 0) {
      _devices[index] = device;
    } else {
      _devices.add(device);
    }
    notifyListeners();
  }

  void updateDeviceStatus(String imei, String newStatus, {String? certId}) {
    final index = _devices.indexWhere((d) => d.imei == imei);
    if (index >= 0) {
      _devices[index] = _devices[index].copyWith(
        status: newStatus,
        certificateId: certId ?? _devices[index].certificateId,
      );
      notifyListeners();
    }
  }
}

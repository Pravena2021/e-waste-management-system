class DeviceModel {
  final String imei;
  final String model;
  final String conditionTag;
  final String status;
  final String? certificateId;

  DeviceModel({
    required this.imei,
    required this.model,
    required this.conditionTag,
    required this.status,
    this.certificateId,
  });

  DeviceModel copyWith({
    String? imei,
    String? model,
    String? conditionTag,
    String? status,
    String? certificateId,
  }) {
    return DeviceModel(
      imei: imei ?? this.imei,
      model: model ?? this.model,
      conditionTag: conditionTag ?? this.conditionTag,
      status: status ?? this.status,
      certificateId: certificateId ?? this.certificateId,
    );
  }
}

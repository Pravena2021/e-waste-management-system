import 'dart:math';

class DeviceAnalysisResult {
  final String deviceModel;
  final int ageMonths;
  final double marketValue;
  final String hardwareHealth;
  final String conditionTag;

  DeviceAnalysisResult({
    required this.deviceModel,
    required this.ageMonths,
    required this.marketValue,
    required this.hardwareHealth,
    required this.conditionTag,
  });
}

class AiAnalysisService {
  Future<DeviceAnalysisResult> analyzeDevice(String imei) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Deterministic mock based on the last character of the IMEI
    final lastChar = imei.isNotEmpty ? imei.characters.last : '0';
    final seed = int.tryParse(lastChar) ?? Random().nextInt(10);
    
    String model;
    String health;
    int age;
    
    // Simple logic to generate different outcomes based on the seed
    if (seed < 3) {
      model = "iPhone 14 Pro";
      health = "Excellent";
      age = 12;
    } else if (seed < 7) {
      model = "Samsung Galaxy S21";
      health = "Fair";
      age = 36;
    } else {
      model = "Generic Android Legacy";
      health = "Poor";
      age = 72;
    }

    String conditionTag;
    double marketValue;
    
    if (health == "Excellent" && age <= 24) {
      conditionTag = "Rare/High-Value";
      marketValue = 850.0;
    } else if (health == "Poor" || age >= 60) {
      conditionTag = "Non-Repairable";
      marketValue = 0.0;
    } else {
      conditionTag = "Repairable";
      marketValue = 150.0;
    }

    return DeviceAnalysisResult(
      deviceModel: model,
      ageMonths: age,
      marketValue: marketValue,
      hardwareHealth: health,
      conditionTag: conditionTag,
    );
  }
}

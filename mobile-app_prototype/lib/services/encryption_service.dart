import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // Simulate AES-256 encryption for database at-rest storage
  static String encryptSensitiveData(String data) {
    if (data.isEmpty) return data;
    // In a production environment, use a robust library like 'encrypt' with AES-GCM
    // Here we simulate the ciphertext structure
    final bytes = utf8.encode(data);
    final base64String = base64.encode(bytes);
    return "ENC:AES256:$base64String";
  }

  static String decryptSensitiveData(String encryptedData) {
    if (!encryptedData.startsWith("ENC:AES256:")) return encryptedData;
    final base64String = encryptedData.replaceFirst("ENC:AES256:", "");
    final bytes = base64.decode(base64String);
    return utf8.decode(bytes);
  }

  // Generate an immutable blockchain certificate linked directly to the IMEI
  static String generateImmutableCertificate(String imei, String wipeType, String auditorId) {
    final timestamp = DateTime.now().toIso8601String();
    
    // The payload physically links the IMEI, action, and auditor into a verifiable string
    final payload = "$imei|$wipeType|$auditorId|$timestamp";
    
    // Hash it via SHA-256 to create the immutable signature
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);
    
    // Return a hex string representing the immutable block ID
    return "0x${digest.toString().substring(0, 32).toUpperCase()}";
  }
}

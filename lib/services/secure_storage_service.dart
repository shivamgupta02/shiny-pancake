import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _pinKey = 'user_pin_hash';
  static const _storage = FlutterSecureStorage();

  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> storePin(String pinHash) async {
    await _storage.write(key: _pinKey, value: pinHash);
  }

  Future<String?> getPin() async {
    return _storage.read(key: _pinKey);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await getPin();
    if (storedHash == null) return false;
    return hashPin(pin) == storedHash;
  }
}

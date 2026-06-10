import 'package:flutter/services.dart';

class SmsReaderService {
  static const _channel = MethodChannel('com.expensecalculator/sms');

  /// Requests READ_SMS permission from the user.
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Checks if READ_SMS permission is currently granted.
  Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Reads SMS messages from the last [days] days.
  /// Returns a list of maps with keys: body (String), date (int millis), sender (String).
  Future<List<Map<String, dynamic>>> readMessages(int days) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'readMessages',
        {'days': days},
      );

      if (result == null) return [];

      return result
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  /// Reads pending messages captured by the BroadcastReceiver while app was in background.
  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getPendingMessages',
      );

      if (result == null) return [];

      return result
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  /// Clears pending messages after they've been processed.
  Future<void> clearPendingMessages() async {
    try {
      await _channel.invokeMethod<bool>('clearPendingMessages');
    } on PlatformException {
      // ignore
    }
  }
}

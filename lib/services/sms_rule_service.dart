import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/sms_rule.dart';

class SmsRuleService {
  static const String _boxName = 'sms_rules';

  Box get _box => Hive.box(_boxName);

  Future<void> saveRule(SmsRule rule) async {
    await _box.put(rule.sender, rule.toMap());
  }

  Future<SmsRule?> getRuleForSender(String sender) async {
    final data = _box.get(sender);
    if (data == null) return null;
    return SmsRule.fromMap(Map<dynamic, dynamic>.from(data as Map));
  }

  Future<List<SmsRule>> getAllRules() async {
    return _box.values
        .map((data) => SmsRule.fromMap(Map<dynamic, dynamic>.from(data as Map)))
        .toList();
  }

  Future<void> deleteRule(String sender) async {
    await _box.delete(sender);
  }

  Future<void> incrementSuccess(String sender) async {
    final rule = await getRuleForSender(sender);
    if (rule == null) return;
    await saveRule(rule.copyWith(successCount: rule.successCount + 1));
  }

  /// Analyzes the raw SMS body and creates a parsing rule by finding where
  /// the correct values appear in the text and building regex patterns
  /// with surrounding context as anchors.
  SmsRule? learnFromCorrection({
    required String rawBody,
    required String sender,
    required double correctAmount,
    String? correctMerchant,
    required DateTime correctDate,
  }) {
    final amountPattern = _buildAmountPattern(rawBody, correctAmount);
    final merchantPattern = correctMerchant != null
        ? _buildMerchantPattern(rawBody, correctMerchant)
        : null;
    final datePattern = _buildDatePattern(rawBody, correctDate);

    // Only create a rule if we could build at least an amount pattern
    if (amountPattern == null) return null;

    return SmsRule(
      sender: sender,
      amountPattern: amountPattern,
      merchantPattern: merchantPattern,
      datePattern: datePattern,
      sampleBody: rawBody,
      createdAt: DateTime.now(),
    );
  }

  /// Finds the amount string in the body and builds a regex with prefix anchor.
  String? _buildAmountPattern(String rawBody, double amount) {
    // Try exact representations of the amount
    final candidates = _amountCandidates(amount);

    for (final candidate in candidates) {
      final index = rawBody.indexOf(candidate);
      if (index == -1) continue;

      // Take up to 15 chars before as prefix anchor
      final prefixStart = (index - 15).clamp(0, rawBody.length);
      final prefix = rawBody.substring(prefixStart, index);

      // Escape the prefix for regex use
      final escapedPrefix = RegExp.escape(prefix.trimLeft());

      if (escapedPrefix.isEmpty) {
        return r'([0-9,]+\.?\d*)';
      }

      return '$escapedPrefix([0-9,]+\\.?\\d*)';
    }

    return null;
  }

  /// Generates different string representations of an amount for matching.
  List<String> _amountCandidates(double amount) {
    final candidates = <String>[];

    // Exact decimal representation
    final exact = amount.toStringAsFixed(2);
    candidates.add(exact);

    // Without trailing zeros (e.g., 3610.96 stays, 100.00 becomes 100)
    if (amount == amount.truncateToDouble()) {
      candidates.add(amount.toInt().toString());
    }

    // With commas (Indian format: 3,610.96)
    final parts = exact.split('.');
    final intPart = parts[0];
    if (intPart.length > 3) {
      final formatted = _formatIndianNumber(intPart);
      candidates.add('$formatted.${parts[1]}');
      if (amount == amount.truncateToDouble()) {
        candidates.add(formatted);
      }
    }

    return candidates;
  }

  String _formatIndianNumber(String number) {
    if (number.length <= 3) return number;

    final lastThree = number.substring(number.length - 3);
    final remaining = number.substring(0, number.length - 3);

    final buffer = StringBuffer();
    for (var i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);

    return buffer.toString();
  }

  /// Finds the merchant string in the body and builds a regex with
  /// prefix and suffix anchors.
  String? _buildMerchantPattern(String rawBody, String merchant) {
    final index = rawBody.toLowerCase().indexOf(merchant.toLowerCase());
    if (index == -1) return null;

    final endIndex = index + merchant.length;

    // Take up to 10 chars before as prefix anchor
    final prefixStart = (index - 10).clamp(0, rawBody.length);
    final prefix = rawBody.substring(prefixStart, index);

    // Take up to 10 chars after as suffix anchor
    final suffixEnd = (endIndex + 10).clamp(0, rawBody.length);
    final suffix = rawBody.substring(endIndex, suffixEnd);

    final escapedPrefix = RegExp.escape(prefix.trimLeft());
    final escapedSuffix = RegExp.escape(suffix.trimRight());

    if (escapedPrefix.isEmpty && escapedSuffix.isEmpty) return null;

    if (escapedSuffix.isEmpty) {
      return '$escapedPrefix(.+)';
    }

    return '$escapedPrefix(.+?)$escapedSuffix';
  }

  /// Finds a date pattern near the correct date in the body.
  String? _buildDatePattern(String rawBody, DateTime date) {
    // Try common date formats that might appear in the SMS
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthAbbrevs = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthAbbr = monthAbbrevs[date.month];
    final yearShort = (date.year % 100).toString().padLeft(2, '0');
    final yearFull = date.year.toString();
    final monthStr = date.month.toString().padLeft(2, '0');

    // Try DD-MMM-YY, DD/MMM/YY, DD-MMM-YYYY
    final dateCandidates = [
      '$dayStr-$monthAbbr-$yearShort',
      '$dayStr/$monthAbbr/$yearFull',
      '$dayStr-$monthAbbr-$yearFull',
      '${date.day}-$monthAbbr-$yearShort',
      '${date.day}/$monthAbbr/$yearShort',
      '$dayStr/$monthStr/$yearFull',
      '${date.day}/$monthStr/$yearFull',
      '$dayStr-$monthStr-$yearFull',
    ];

    for (final candidate in dateCandidates) {
      final index = rawBody.indexOf(candidate);
      if (index == -1) continue;

      // Take up to 10 chars before as prefix anchor
      final prefixStart = (index - 10).clamp(0, rawBody.length);
      final prefix = rawBody.substring(prefixStart, index);
      final escapedPrefix = RegExp.escape(prefix.trimLeft());

      if (escapedPrefix.isEmpty) {
        return r'(\d{1,2}[-/]\w{3}[-/]\d{2,4})';
      }

      return '$escapedPrefix(\\d{1,2}[-/]\\w{3}[-/]\\d{2,4})';
    }

    return null;
  }
}

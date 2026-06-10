import '../data/models/detected_expense.dart';
import '../data/models/sms_rule.dart';

class SmsParsingService {
  static const _debitKeywords = [
    'debited',
    'spent',
    'paid',
    'withdrawn',
    'charged',
    'deducted',
  ];

  static const _exclusionKeywords = [
    'credited',
    'otp',
    'one time password',
  ];

  static const _amountIndicators = ['rs.', 'rs', 'inr', '₹'];

  static final _amountRegex = RegExp(
    r'(?:Rs\.?|INR|₹)\s*([0-9,]+\.?\d*)',
    caseSensitive: false,
  );

  static final _merchantUpiRegex = RegExp(
    r'UPI/([^/]+)',
    caseSensitive: false,
  );

  static final _merchantAtRegex = RegExp(
    r'\bat\s+([A-Za-z0-9][\w\s&.\-]{1,30})',
    caseSensitive: false,
  );

  static final _merchantToRegex = RegExp(
    r'\bto\s+([A-Za-z0-9][\w\s&.\-]{1,30})',
    caseSensitive: false,
  );

  // Axis Bank format: "Spent INR 3610.96 Axis Bank Card no XX3333 DATE MerchantName Avl limit"
  static final _merchantAfterDateRegex = RegExp(
    r'\d{1,2}[-/]\w{3}[-/]?\d{0,4}\s+(.+?)\s*(?:Avl|Available|Not you)',
    caseSensitive: false,
  );

  // Pattern: "Card no XXNNNN DATE MerchantName Avl"
  static final _merchantAfterCardRegex = RegExp(
    r'Card\s+no\s+\w+\s+\d{1,2}[-/]\w{3}[-/]?\d{0,4}\s+(.+?)\s*(?:Avl|Available|Not you)',
    caseSensitive: false,
  );

  static final _dateDdMmmYyRegex = RegExp(
    r'(\d{1,2})[-/]([A-Za-z]{3})[-/](\d{2,4})',
  );

  static final _dateDdMmYyyyRegex = RegExp(
    r'(\d{1,2})/(\d{1,2})/(\d{2,4})',
  );

  static const _knownBankSenders = [
    'sbi',
    'hdfc',
    'icici',
    'axis',
    'kotak',
    'pnb',
    'bob',
    'canara',
    'union',
    'idbi',
    'yes bank',
    'indusind',
    'federal',
    'rbl',
  ];

  /// Quick keyword check to determine if an SMS is likely a transaction message.
  bool isTransactionSms(String body) {
    final lower = body.toLowerCase();

    // Check exclusion keywords first
    for (final keyword in _exclusionKeywords) {
      if (lower.contains(keyword)) return false;
    }

    // Must contain a debit keyword
    final hasDebitKeyword = _debitKeywords.any((k) => lower.contains(k));
    if (!hasDebitKeyword) return false;

    // Must contain an amount indicator
    final hasAmountIndicator = _amountIndicators.any((k) => lower.contains(k));
    return hasAmountIndicator;
  }

  /// Full extraction of expense data from an SMS body.
  /// Returns null if the message doesn't appear to be a valid transaction.
  /// If a [rule] is provided, it will be tried first before generic patterns.
  DetectedExpense? parseMessage(
    String body, {
    DateTime? smsDate,
    SmsRule? rule,
    String? sender,
  }) {
    // Try learned rule first if available
    if (rule != null) {
      final ruleResult = parseWithRule(body, rule, smsDate: smsDate);
      if (ruleResult != null) {
        return ruleResult.copyWith(sender: sender);
      }
    }

    if (!isTransactionSms(body)) return null;

    final amount = extractAmount(body);
    if (amount == null || amount <= 0) return null;

    final now = DateTime.now();
    final effectiveSmsDate = smsDate ?? now;
    final merchant = extractMerchant(body);
    final date = extractDate(body, effectiveSmsDate);

    final confidence = calculateConfidence(
      amount: amount,
      merchant: merchant,
      date: date,
      smsDate: effectiveSmsDate,
      body: body,
    );

    return DetectedExpense(
      amount: amount,
      merchant: merchant,
      date: date,
      rawSmsBody: body,
      smsDate: effectiveSmsDate,
      confidence: confidence,
      sender: sender,
    );
  }

  /// Applies a learned rule to parse the SMS.
  /// Returns null if the rule's patterns don't match, allowing fallback.
  DetectedExpense? parseWithRule(
    String body,
    SmsRule rule, {
    DateTime? smsDate,
  }) {
    final effectiveSmsDate = smsDate ?? DateTime.now();
    double? amount;
    String? merchant;
    DateTime date = effectiveSmsDate;

    // Try amount pattern
    if (rule.amountPattern != null) {
      try {
        final regex = RegExp(rule.amountPattern!, caseSensitive: false);
        final match = regex.firstMatch(body);
        if (match != null && match.groupCount >= 1) {
          final raw = match.group(1)?.replaceAll(',', '');
          amount = raw != null ? double.tryParse(raw) : null;
        }
      } catch (_) {
        // Invalid regex, skip
      }
    }

    // If we couldn't extract amount from rule, rule failed
    if (amount == null || amount <= 0) return null;

    // Try merchant pattern
    if (rule.merchantPattern != null) {
      try {
        final regex = RegExp(rule.merchantPattern!, caseSensitive: false);
        final match = regex.firstMatch(body);
        if (match != null && match.groupCount >= 1) {
          final raw = match.group(1)?.trim();
          if (raw != null && raw.isNotEmpty) {
            merchant = raw;
          }
        }
      } catch (_) {
        // Invalid regex, skip
      }
    }

    // Try date pattern
    if (rule.datePattern != null) {
      try {
        final regex = RegExp(rule.datePattern!, caseSensitive: false);
        final match = regex.firstMatch(body);
        if (match != null && match.groupCount >= 1) {
          final dateStr = match.group(1);
          if (dateStr != null) {
            date = extractDate(dateStr, effectiveSmsDate);
          }
        }
      } catch (_) {
        // Invalid regex, skip
      }
    }

    return DetectedExpense(
      amount: amount,
      merchant: merchant,
      date: date,
      rawSmsBody: body,
      smsDate: effectiveSmsDate,
      confidence: 0.9, // High confidence for learned rules
      sender: rule.sender,
    );
  }

  /// Extracts the transaction amount from the SMS text.
  double? extractAmount(String text) {
    final match = _amountRegex.firstMatch(text);
    if (match == null) return null;

    final rawAmount = match.group(1);
    if (rawAmount == null) return null;

    // Remove commas and parse
    final cleaned = rawAmount.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  /// Extracts merchant name from the SMS text using multiple patterns.
  String? extractMerchant(String text) {
    // Try UPI pattern first (most specific)
    final upiMatch = _merchantUpiRegex.firstMatch(text);
    if (upiMatch != null) {
      return _cleanMerchant(upiMatch.group(1));
    }

    // Try Axis Bank / Card format: "Card no XXNNNN DATE MerchantName Avl limit"
    final cardMatch = _merchantAfterCardRegex.firstMatch(text);
    if (cardMatch != null) {
      return _cleanMerchant(cardMatch.group(1));
    }

    // Try generic "after date before Avl" pattern
    final afterDateMatch = _merchantAfterDateRegex.firstMatch(text);
    if (afterDateMatch != null) {
      return _cleanMerchant(afterDateMatch.group(1));
    }

    // Try "at" pattern
    final atMatch = _merchantAtRegex.firstMatch(text);
    if (atMatch != null) {
      return _cleanMerchant(atMatch.group(1));
    }

    // Try "to" pattern
    final toMatch = _merchantToRegex.firstMatch(text);
    if (toMatch != null) {
      return _cleanMerchant(toMatch.group(1));
    }

    return null;
  }

  /// Extracts the transaction date from the SMS text.
  /// Falls back to the provided fallback date if no date pattern is found.
  DateTime extractDate(String text, DateTime fallback) {
    // Try DD-MMM-YY pattern (e.g., 15-Jun-24, 15/Jun/2024)
    final dmmyMatch = _dateDdMmmYyRegex.firstMatch(text);
    if (dmmyMatch != null) {
      final parsed = _parseDdMmmYy(
        dmmyMatch.group(1)!,
        dmmyMatch.group(2)!,
        dmmyMatch.group(3)!,
      );
      if (parsed != null) return parsed;
    }

    // Try DD/MM/YYYY pattern
    final dmyMatch = _dateDdMmYyyyRegex.firstMatch(text);
    if (dmyMatch != null) {
      final parsed = _parseDdMmYyyy(
        dmyMatch.group(1)!,
        dmyMatch.group(2)!,
        dmyMatch.group(3)!,
      );
      if (parsed != null) return parsed;
    }

    return fallback;
  }

  /// Calculates confidence score for the detected expense.
  double calculateConfidence({
    required double? amount,
    required String? merchant,
    required DateTime date,
    required DateTime smsDate,
    required String body,
  }) {
    double score = 0.0;

    // Amount extracted: +0.4
    if (amount != null && amount > 0) score += 0.4;

    // Merchant extracted: +0.3
    if (merchant != null && merchant.isNotEmpty) score += 0.3;

    // Date extracted (not same as smsDate fallback): +0.2
    if (date != smsDate) score += 0.2;

    // Known bank sender in body: +0.1
    final lower = body.toLowerCase();
    final isKnownBank = _knownBankSenders.any((bank) => lower.contains(bank));
    if (isKnownBank) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  String? _cleanMerchant(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // Remove trailing punctuation and common noise
    final cleaned = trimmed
        .replaceAll(RegExp(r'[.\s]+$'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    return cleaned.isEmpty ? null : cleaned;
  }

  DateTime? _parseDdMmmYy(String day, String month, String year) {
    final d = int.tryParse(day);
    if (d == null || d < 1 || d > 31) return null;

    final m = _monthFromAbbrev(month);
    if (m == null) return null;

    var y = int.tryParse(year);
    if (y == null) return null;
    if (y < 100) y += 2000;

    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDdMmYyyy(String day, String month, String year) {
    final d = int.tryParse(day);
    final m = int.tryParse(month);
    var y = int.tryParse(year);

    if (d == null || m == null || y == null) return null;
    if (d < 1 || d > 31 || m < 1 || m > 12) return null;
    if (y < 100) y += 2000;

    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  int? _monthFromAbbrev(String abbrev) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return months[abbrev.toLowerCase()];
  }
}

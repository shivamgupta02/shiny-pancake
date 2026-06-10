import 'package:flutter/foundation.dart';

@immutable
sealed class ExportEvent {
  const ExportEvent();
}

class ExportToExcel extends ExportEvent {
  final DateTime dateFrom;
  final DateTime dateTo;
  final List<String>? categoryIds;

  const ExportToExcel({
    required this.dateFrom,
    required this.dateTo,
    this.categoryIds,
  });
}

class ExportToPdf extends ExportEvent {
  final DateTime month;

  const ExportToPdf({required this.month});
}

class ShareExportedFile extends ExportEvent {
  final String filePath;

  const ShareExportedFile({required this.filePath});
}

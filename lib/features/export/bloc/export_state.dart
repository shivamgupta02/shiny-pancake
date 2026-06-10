import 'package:flutter/foundation.dart';

@immutable
sealed class ExportState {
  const ExportState();
}

class ExportInitial extends ExportState {
  const ExportInitial();
}

class ExportInProgress extends ExportState {
  final String message;

  const ExportInProgress(this.message);
}

class ExportSuccess extends ExportState {
  final String filePath;

  const ExportSuccess(this.filePath);
}

class ExportError extends ExportState {
  final String message;

  const ExportError(this.message);
}

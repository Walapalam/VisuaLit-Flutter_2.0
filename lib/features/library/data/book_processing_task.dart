import 'dart:typed_data';

enum TaskStatus {
  queued,
  running,
  completed,
  failed
}

class BookProcessingTask {
  final int id;
  final String filePath;
  final Uint8List fileBytes;
  TaskStatus status;
  DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;
  String? errorMessage;
  StackTrace? errorStackTrace;
  int retryCount;
  DateTime? lastTriedAt;
  bool failedPermanently;

  BookProcessingTask({
    required this.id,
    required this.filePath,
    required this.fileBytes,
    this.status = TaskStatus.queued,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.errorStackTrace,
    this.retryCount = 0,
    this.lastTriedAt,
    this.failedPermanently = false,
  }) : createdAt = createdAt ?? DateTime.now();

  BookProcessingTask copyWith({
    int? id,
    String? filePath,
    Uint8List? fileBytes,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    StackTrace? errorStackTrace,
    int? retryCount,
    DateTime? lastTriedAt,
    bool? failedPermanently,
  }) {
    return BookProcessingTask(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileBytes: fileBytes ?? this.fileBytes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      errorStackTrace: errorStackTrace ?? this.errorStackTrace,
      retryCount: retryCount ?? this.retryCount,
      lastTriedAt: lastTriedAt ?? this.lastTriedAt,
      failedPermanently: failedPermanently ?? this.failedPermanently,
    );
  }
}

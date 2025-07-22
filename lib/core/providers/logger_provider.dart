import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/core/services/logger_service.dart';

/// Provider for the LoggerService.
/// 
/// This provider creates and provides a singleton instance of the LoggerService
/// that implements the ILoggerService interface.
final loggerServiceProvider = Provider<ILoggerService>((ref) {
  return LoggerService();
});
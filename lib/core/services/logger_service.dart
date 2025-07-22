import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';

/// Implementation of the ILoggerService interface.
/// 
/// This service provides logging functionality with different log levels
/// and support for remote logging in production.
class LoggerService implements ILoggerService {
  /// Whether to enable debug logs.
  final bool _debugLogsEnabled;
  
  /// Whether to enable remote logging (e.g., to Crashlytics or Sentry).
  final bool _remoteLoggingEnabled;
  
  /// Creates a new LoggerService.
  /// 
  /// [debugLogsEnabled] controls whether debug logs are shown (defaults to true in debug mode).
  /// [remoteLoggingEnabled] controls whether logs are sent to remote services (defaults to true in release mode).
  LoggerService({
    bool? debugLogsEnabled,
    bool? remoteLoggingEnabled,
  }) : 
    _debugLogsEnabled = debugLogsEnabled ?? kDebugMode,
    _remoteLoggingEnabled = remoteLoggingEnabled ?? kReleaseMode;
  
  @override
  void log(String message, {String? tag}) {
    _printLog('LOG', message, tag);
    _sendToRemoteIfEnabled('LOG', message, tag);
  }

  @override
  void error(String message, {String? tag, StackTrace? stackTrace}) {
    _printLog('ERROR', message, tag);
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
    _sendToRemoteIfEnabled('ERROR', message, tag, stackTrace);
  }

  @override
  void warning(String message, {String? tag}) {
    _printLog('WARNING', message, tag);
    _sendToRemoteIfEnabled('WARNING', message, tag);
  }

  @override
  void info(String message, {String? tag}) {
    _printLog('INFO', message, tag);
    _sendToRemoteIfEnabled('INFO', message, tag);
  }

  @override
  void debug(String message, {String? tag}) {
    if (_debugLogsEnabled) {
      _printLog('DEBUG', message, tag);
    }
  }
  
  /// Prints a log message to the console.
  void _printLog(String level, String message, String? tag) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    developer.log('$timestamp $level $tagStr: $message');
  }
  
  /// Sends a log message to remote logging services if enabled.
  void _sendToRemoteIfEnabled(String level, String message, String? tag, [StackTrace? stackTrace]) {
    if (!_remoteLoggingEnabled) return;
    
    // In a real implementation, this would send logs to Crashlytics, Sentry, etc.
    // For example:
    // FirebaseCrashlytics.instance.log('$level ${tag != null ? "[$tag]" : ""}: $message');
    // if (level == 'ERROR' && stackTrace != null) {
    //   FirebaseCrashlytics.instance.recordError(message, stackTrace);
    // }
  }
}
/// Interface for logging service.
/// 
/// This interface defines the contract for logging services in the application.
/// It provides methods for different log levels and supports tagging for better filtering.
abstract class ILoggerService {
  /// Logs a general message.
  void log(String message, {String? tag});
  
  /// Logs an error message with optional stack trace.
  void error(String message, {String? tag, StackTrace? stackTrace});
  
  /// Logs a warning message.
  void warning(String message, {String? tag});
  
  /// Logs an informational message.
  void info(String message, {String? tag});
  
  /// Logs a debug message (only in development).
  void debug(String message, {String? tag});
}
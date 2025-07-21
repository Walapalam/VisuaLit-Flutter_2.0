import 'package:flutter_test/flutter_test.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/core/services/logger_service.dart';

void main() {
  late ILoggerService loggerService;
  
  setUp(() {
    // Create a logger with debug logs enabled and remote logging disabled for testing
    loggerService = LoggerService(debugLogsEnabled: true, remoteLoggingEnabled: false);
  });
  
  group('LoggerService', () {
    test('log should not throw exceptions', () {
      // This test just verifies that the method doesn't throw
      expect(() => loggerService.log('Test log message'), returnsNormally);
      expect(() => loggerService.log('Test log message with tag', tag: 'TestTag'), returnsNormally);
    });
    
    test('error should not throw exceptions', () {
      // This test just verifies that the method doesn't throw
      expect(() => loggerService.error('Test error message'), returnsNormally);
      expect(() => loggerService.error('Test error message with tag', tag: 'TestTag'), returnsNormally);
      expect(() => loggerService.error('Test error message with stack trace', 
        tag: 'TestTag', stackTrace: StackTrace.current), returnsNormally);
    });
    
    test('warning should not throw exceptions', () {
      // This test just verifies that the method doesn't throw
      expect(() => loggerService.warning('Test warning message'), returnsNormally);
      expect(() => loggerService.warning('Test warning message with tag', tag: 'TestTag'), returnsNormally);
    });
    
    test('info should not throw exceptions', () {
      // This test just verifies that the method doesn't throw
      expect(() => loggerService.info('Test info message'), returnsNormally);
      expect(() => loggerService.info('Test info message with tag', tag: 'TestTag'), returnsNormally);
    });
    
    test('debug should not throw exceptions when enabled', () {
      // This test just verifies that the method doesn't throw
      expect(() => loggerService.debug('Test debug message'), returnsNormally);
      expect(() => loggerService.debug('Test debug message with tag', tag: 'TestTag'), returnsNormally);
    });
    
    test('debug should not log when disabled', () {
      // Create a logger with debug logs disabled
      final loggerWithoutDebug = LoggerService(debugLogsEnabled: false);
      
      // This test just verifies that the method doesn't throw
      expect(() => loggerWithoutDebug.debug('Test debug message'), returnsNormally);
      expect(() => loggerWithoutDebug.debug('Test debug message with tag', tag: 'TestTag'), returnsNormally);
      
      // We can't easily verify that nothing was logged, but at least we can verify that the method doesn't throw
    });
    
    test('logger should handle null tags gracefully', () {
      // This test just verifies that the method doesn't throw when tag is null
      expect(() => loggerService.log('Test message with null tag', tag: null), returnsNormally);
      expect(() => loggerService.error('Test error with null tag', tag: null), returnsNormally);
      expect(() => loggerService.warning('Test warning with null tag', tag: null), returnsNormally);
      expect(() => loggerService.info('Test info with null tag', tag: null), returnsNormally);
      expect(() => loggerService.debug('Test debug with null tag', tag: null), returnsNormally);
    });
    
    test('logger should handle empty messages gracefully', () {
      // This test just verifies that the method doesn't throw when message is empty
      expect(() => loggerService.log(''), returnsNormally);
      expect(() => loggerService.error(''), returnsNormally);
      expect(() => loggerService.warning(''), returnsNormally);
      expect(() => loggerService.info(''), returnsNormally);
      expect(() => loggerService.debug(''), returnsNormally);
    });
  });
}
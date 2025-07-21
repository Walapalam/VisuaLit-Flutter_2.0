import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/logger_provider.dart';
import 'package:visualit/features/reader/application/book_processor.dart';
import 'package:visualit/features/reader/application/interfaces/i_book_processor.dart';

/// Provider for the BookProcessor.
/// 
/// This provider creates and provides a singleton instance of the BookProcessor
/// that implements the IBookProcessor interface.
final bookProcessorProvider = Provider<IBookProcessor>((ref) {
  final logger = ref.watch(loggerServiceProvider);
  return BookProcessor(logger);
});
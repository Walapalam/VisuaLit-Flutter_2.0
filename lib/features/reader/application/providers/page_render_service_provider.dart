import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/core/providers/logger_provider.dart';
import 'package:visualit/features/reader/application/enhanced_page_render_service.dart';
import 'package:visualit/features/reader/application/interfaces/i_page_render_service.dart';
import 'package:visualit/features/reader/application/page_render_service.dart';

/// Provider for the PageRenderService.
/// 
/// This provider creates and provides a singleton instance of the EnhancedPageRenderService
/// that implements the IPageRenderService interface.
final pageRenderServiceProvider = Provider<IPageRenderService>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final logger = ref.watch(loggerServiceProvider);
  
  // Create the original service
  final originalService = PageRenderService(isar);
  
  // Wrap it with the enhanced service
  return EnhancedPageRenderService(originalService, logger);
});
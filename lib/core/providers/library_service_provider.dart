import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/library/data/local_library_service.dart';

/// Provider for the LocalLibraryService
final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

/// Provider for requesting all permissions
/// This is a future provider that will request all permissions when accessed
final permissionsProvider = FutureProvider<bool>((ref) async {
  final libraryService = ref.watch(localLibraryServiceProvider);
  return await libraryService.requestAllPermissions();
});
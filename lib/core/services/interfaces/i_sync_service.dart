/// Interface for synchronization service.
/// 
/// This interface defines the contract for services that synchronize data
/// between local database and remote storage.
abstract class ISyncService {
  /// Synchronizes all user data between local database and remote storage.
  /// 
  /// This method should handle synchronization of all entity types
  /// (highlights, bookmarks, reading progress, etc.) and resolve any conflicts.
  Future<void> syncUserData();
  
  /// Synchronizes a specific entity to remote storage.
  /// 
  /// This method can be used to immediately sync a single entity
  /// without waiting for the next full sync cycle.
  /// 
  /// [entity] is the entity to synchronize.
  Future<void> syncEntity(dynamic entity);
}
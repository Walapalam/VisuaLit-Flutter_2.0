import 'package:isar/isar.dart';

/// Abstract class for entities that can be synchronized across devices.
/// 
/// This class provides the common fields and functionality needed for
/// synchronization, such as a unique sync ID, last modified timestamp,
/// and a dirty flag to indicate pending sync.
abstract class SyncableEntity {
  /// Unique identifier for synchronization across devices.
  /// This is typically a UUID or Appwrite Document ID.
  String? syncId;

  /// Timestamp of when this entity was last modified.
  /// Used for conflict resolution during synchronization.
  DateTime lastModified = DateTime.now();

  /// Flag indicating whether this entity has local changes
  /// that need to be synchronized to the server.
  bool isDirty = true;

  /// Updates the lastModified timestamp to the current time
  /// and marks the entity as dirty.
  void markDirty() {
    lastModified = DateTime.now();
    isDirty = true;
  }
}
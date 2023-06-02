
/// Utility for generating temporary ids for new objects.
/// 
/// Using 'null' for new objects can be inconvenient (e.g. you cannot
/// place them in Maps by id).  This class provides a standard way to create a
/// recognizable "new" identifier prior to an object recieving a real identifier
/// from a persistent store.
class AFDocumentIDGenerator {
  /// Prefix for objects that have not yet been stored to firebase.
  static const newId = 'newId';
  static const testId = 'testId';
  static const columnId = "id";
  static int gNewId = 100;

  /// Creates a temporary object id for an object that has not yet been saved to firestore.
  static String createNewId(String suffix) {
    gNewId++;
    return "${newId}_${suffix.toString()}_${gNewId.toString()}";
  }

  /// Returns true of the specified id was returned by [createNewId]
  static bool isNewId(String? id) {
    if(id == null) {
      return false;
    }
    return id.startsWith(newId);
  }

  /// Returns a new unique ID useful intesting.
  /// 
  /// The id contains the specified suffix and a monotonically increasing
  /// integer.
  static String createTestIdIncreasing(String suffix) {
    gNewId++;
    return "${testId}_${suffix}_$gNewId";
  }

}

/// Utility for generating temporary ids for new objects
/// 
/// Using 'null' for new objects can be inconvenient (e.g. you cannot
/// place them in Maps by id).  afib_firebase uses this to determine
/// if an object is new based on its ID.  It is included in 
/// afib so that you don't need to drag afib_firebase into your library
/// just to get this functionality.
class AFDocumentIDGenerator {
  /// Prefix for objects that have not yet been stored to firebase.
  static const newId = 'newId';
  static const testId = 'testId';
  static int gNewId = 100;

  /// Creates a temporary object id for an object that has not yet been saved to firestore.
  static String createNewId(String suffix) {
    gNewId++;
    return "${newId}_${suffix.toString()}_${gNewId.toString()}";
  }

  static bool isNewId(String? id) {
    if(id == null) {
      return false;
    }
    return id.startsWith(newId);
  }

  static String createTestIdIncreasing(String suffix) {
    gNewId++;
    return "${testId}_${suffix}_$gNewId";
  }

}
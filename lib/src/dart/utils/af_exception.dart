
/// Used for errors thrown by Afib.
class AFException implements Exception {
  String cause;
  AFException(this.cause);

  String toString() {
    return cause;
  }
}

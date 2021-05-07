
/// Used for errors thrown by Afib.
class AFException implements Exception {
  String cause;
  AFException(this.cause);

  String toString() {
    return cause;
  }
}

class AFCommandError implements Exception {
  String cause;
  AFCommandError(this.cause);

  String toString() {
    return this.cause;
  }
}
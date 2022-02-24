
/// Used for errors thrown by Afib.
class AFException implements Exception {
  String cause;
  AFException(this.cause);

  factory AFException.missingState(String item) {
    return AFException("Missing state: $item");
  }

  String toString() {
    return cause;
  }
}

class AFExceptionStopHere extends AFException {
  AFExceptionStopHere(): super("debug stop here");
}
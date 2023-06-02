
/// Thrown by AFib to indicate problems in runtime contexts.
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

/// Used by AFib to stop a state test where it is.  
/// 
/// See [AFStateTestScreenContext.executeDebugStopHere] or 
/// [AFStateTest.executeDebugStopHere].
class AFExceptionStopHere extends AFException {
  AFExceptionStopHere(): super("debug stop here");
}
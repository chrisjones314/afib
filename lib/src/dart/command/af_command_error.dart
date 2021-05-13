class AFCommandError implements Exception {
  String cause;
  AFCommandError(this.cause);

  String toString() {
    return this.cause;
  }
}
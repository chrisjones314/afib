class AFCommandError implements Exception {
  String error;
  String? usage;
  AFCommandError({
    required this.error,
    this.usage,
  });

  String toString() {
    return this.error;
  }
}
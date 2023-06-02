
/// If thrown within an AFib command, shows the usage for the command followed by the error message.
/// 
/// You do not need to provide the [usage], AFib will provide it from the command's standard usage. 
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
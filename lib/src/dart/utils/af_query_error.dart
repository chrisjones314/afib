/// A standard way to represent errors that occur during [AFAsyncQuery].
/// 
/// However, you can also use your own error type if you prefer.
class AFQueryError {
  String? message;
  int? code;
  dynamic custom;

  AFQueryError({
    this.message, 
    this.code, 
    this.custom});

  String toString() {
    final sb = StringBuffer();
    if(code != null) {
      sb.write(code);
      if(message != null) {
        sb.write(": ");
      }
    }
    if(message != null) {
      sb.write(message);
    }
    return sb.toString();
  }
}
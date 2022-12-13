/// A standard way to represent errors that occur during [AFAsyncQuery].
/// 
/// However, you can also use your own error type if you prefer.
class AFQueryError {
  static const noMessage = "";
  static const noCode = 0;

  String message;
  int code;
  dynamic custom;

  AFQueryError({
    required this.message, 
    this.code = 100, 
    this.custom});

  factory AFQueryError.createMessage(String message) {
    return AFQueryError(message: message, code: noCode);
  }

  factory AFQueryError.createCode(int code) {
    return AFQueryError(message: noMessage, code: code);
  }

  String toString() {
    final sb = StringBuffer();
    if(code != noCode) {
      sb.write(code);
      if(message != noMessage) {
        sb.write(": ");
      }
    }
    if(message != noMessage) {
      sb.write(message);
    }
    return sb.toString();
  }
}
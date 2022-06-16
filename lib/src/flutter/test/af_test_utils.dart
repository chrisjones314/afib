
class AFTestUtils {
    static String createTestId(String prefix, Object source) {
    final sourceData = source.toString();
    var charCodes = <int>[];

    for (final codeUnit in sourceData.codeUnits) {
      final validNumber = codeUnit > 47 && codeUnit <= 57;
      final validUpper = codeUnit > 64 && codeUnit <= 90;
      final validLower = codeUnit > 96 && codeUnit <= 122;
      if (validNumber || validUpper || validLower) {
        charCodes.add(codeUnit);
      } else {
      }
    }

    return "$prefix${String.fromCharCodes(charCodes)}";  
  }

}
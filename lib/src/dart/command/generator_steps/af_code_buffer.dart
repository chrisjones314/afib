
/// Used to insert code at a particular point in a file.
class AFCodeBuffer {
  int indent = 0;
  final lines = List<String>();
  final currentLine = StringBuffer();

  void writeLine(String line) {
    currentLine.clear();
    lines.add(line);
  }

  String withIndent(String indent) {
    final result = StringBuffer();
    for(int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if(i > 0) {
        result.write(indent);
      }
      result.writeln(line);
    }
    return result.toString();
  }
}

/// Used to insert code at a particular point in a file.
class AFCodeBuffer {
  final String indent;
  final lines = List<String>();
  final currentLine = StringBuffer();

  AFCodeBuffer({this.indent = ""});

  void writeLine(String line) {
    currentLine.write(line);
    lines.add(currentLine.toString());
    currentLine.clear();
  }

  void write(String content) {
    currentLine.write(content);
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
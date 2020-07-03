import 'dart:io';
import 'package:colorize/colorize.dart';

enum AFOutputAlignment {
  alignLeft,
  alignRight
}



class AFCommandOutputColumn {
  AFOutputAlignment alignment;
  Styles color;
  Styles fontStyle;
  int width;
  final StringBuffer content = StringBuffer();

  AFCommandOutputColumn({
    this.alignment,
    this.color,
    this.fontStyle,
    this.width
  });

  int get length { return content.length; }

  void write(String output) {
    content.write(output);
  }

}

/// Used to achieve nicely formatted output for commands.
class AFCommandOutput {
  int nIndent = 0;
  final cols = List<AFCommandOutputColumn>();

  void indent() { nIndent++; }
  void outdent() { nIndent--; }

  void startColumn({AFOutputAlignment alignment, Styles color, Styles fontStyle, int width}) {
    cols.add(AFCommandOutputColumn(
      alignment: alignment ?? AFOutputAlignment.alignLeft,
      color: color ?? Styles.DEFAULT,
      fontStyle: fontStyle ?? Styles.DEFAULT,
      width: width ?? 0
    ));
  }

  void write(String output) {
    if(cols.isEmpty) {
      startColumn(
        alignment: AFOutputAlignment.alignLeft, 
        color: Styles.DEFAULT,
        fontStyle: Styles.DEFAULT, 
        width: 0);
    }

    final col = cols.last;
    col.write(output);
  }

  void writeError(String error) {
    final out = Colorize("ERROR: ").apply(Styles.RED);
    stdout.write(out);
    stdout.write(error);
    stdout.writeln();
  }

  void writeErrorLine(String error) {
    writeError(error);
    endLine();
  }

  void writeLine(String output) {
    write(output);
    endLine();
  }

  void writeSeparatorLine() {
    writeLine("--------------------------------------------------------------------");
  }

  void endLine() {
    _writeSpace(2*nIndent);

    for(var col in cols) {
      if(col.alignment == AFOutputAlignment.alignRight) {
        int req = col.width - col.length;
        _writeSpace(req);
      }

      final out = Colorize(col.content.toString()).apply(col.color);
      stdout.write(out);
      
      if(col.alignment == AFOutputAlignment.alignLeft) {
        int req = col.width - col.length;
        _writeSpace(req);
      }
    }

    stdout.writeln();
    cols.clear();
  }

  void _writeSpace(int count) {
    for(int i = 0; i < count; i++) {
      stdout.write(" ");
    }   
  }

}
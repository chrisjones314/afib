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

  void writeErrorLine(String error) {
    final out = Colorize("ERROR: ").apply(Styles.RED);
    final result = StringBuffer();
    result.write(out);
    result.write(error);
    writeLine(result.toString());
  }

  void writeLine(String output) {
    write(output);
    endLine();
  }

  void writeSeparatorLine() {
    writeLine("------------------------------------");
  }

  void endLine() {
    final sb = StringBuffer();
    _writeSpace(sb, 2*nIndent);

    for(var col in cols) {
      if(col.alignment == AFOutputAlignment.alignRight) {
        int req = col.width - col.length;
        _writeSpace(sb, req);
      }

      final out = Colorize(col.content.toString()).apply(col.color);
      sb.write(out);
      
      if(col.alignment == AFOutputAlignment.alignLeft) {
        int req = col.width - col.length;
        _writeSpace(sb, req);
      }
    }

    print(sb.toString());

    cols.clear();
  }

  void _writeSpace(StringBuffer sb, int count) {
    for(int i = 0; i < count; i++) {
      sb.write(" ");
    }   
  }

}
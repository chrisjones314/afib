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
  String fill;
  final StringBuffer content = StringBuffer();

  AFCommandOutputColumn({
    required this.alignment,
    this.color = Styles.DEFAULT,
    this.fontStyle = Styles.DEFAULT,
    this.width = 0,
    this.fill = " ",
  });

  int get length { return content.length; }

  void write(String output) {
    content.write(output);
  }

}

/// Used to achieve nicely formatted output for commands.
class AFCommandOutput {
  int nIndent = 0;
  final cols = <AFCommandOutputColumn>[];
  final bool colorize;

  AFCommandOutput({
    this.colorize = true,
  });

  void indent() { nIndent++; }
  void outdent() { nIndent--; }

  void startColumn({
    AFOutputAlignment? alignment, 
    Styles? color, 
    Styles? fontStyle, 
    int? width, 
    String fill = " "
  }) {
    cols.add(AFCommandOutputColumn(
      alignment: alignment ?? AFOutputAlignment.alignLeft,
      color: color ?? Styles.DEFAULT,
      fontStyle: fontStyle ?? Styles.DEFAULT,
      width: width ?? 0,
      fill: fill,
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

  void writeTwoColumns({
    required String col1,
    required String col2, 
    int width1 = 15,
    int? width2,
    Styles? color1 = Styles.GREEN,
    Styles? color2,
    AFOutputAlignment? align1 = AFOutputAlignment.alignRight,
    AFOutputAlignment? align2 = AFOutputAlignment.alignLeft,
  }) {
    writeThreeColumns(
      col1: col1, 
      col2: col2,
      width1: width1,
      width2: width2,
      color1: color1,
      color2: color2,
      align1: align1,
      align2: align2,      
    );
  }

  void writeTwoColumnsError({
    String col1 = "error",
    required String col2, 
    int width1 = 15,
    int? width2,
    Styles? color1 = Styles.RED,
    Styles? color2,
    AFOutputAlignment? align1 = AFOutputAlignment.alignRight,
    AFOutputAlignment? align2 = AFOutputAlignment.alignLeft,
  }) {
    writeThreeColumns(
      col1: col1, 
      col2: col2,
      width1: width1,
      width2: width2,
      color1: color1,
      color2: color2,
      align1: align1,
      align2: align2,      
    );
  }

  void writeTwoColumnsWarning({
    String col1 = "warning",
    required String col2, 
    int width1 = 15,
    int? width2,
    Styles? color1 = Styles.YELLOW,
    Styles? color2,
    AFOutputAlignment? align1 = AFOutputAlignment.alignRight,
    AFOutputAlignment? align2 = AFOutputAlignment.alignLeft,
  }) {
    writeThreeColumns(
      col1: col1, 
      col2: col2,
      width1: width1,
      width2: width2,
      color1: color1,
      color2: color2,
      align1: align1,
      align2: align2,      
    );
  }


  void writeThreeColumns({
    required String col1,
    required String col2, 
    String? col3,
    int width1 = 15,
    int? width2,
    int? width3,
    Styles? color1 = Styles.GREEN,
    Styles? color2,
    Styles? color3,
    AFOutputAlignment? align1 = AFOutputAlignment.alignRight,
    AFOutputAlignment? align2 = AFOutputAlignment.alignLeft,
    AFOutputAlignment? align3 = AFOutputAlignment.alignLeft,
  }) {
    startColumn(
      alignment: align1,
      width: width1,
      color: color1);
    write(col1);
    startColumn(
      alignment: align2,
      width: width2,
      color: color2,
    );
    write(col2);
    if(col3 != null) {
      startColumn(
      alignment: align3,
      width: width3,
      color: color3,
      );
      write(col3);
    }
    endLine();
  }

  String _colorize(String value, Styles color) {
    if(colorize) {
      return Colorize(value).apply(color).toString();
    } else {
      return value;
    }
  }

  void writeErrorLine(String error) {
    final out = _colorize("ERROR: ", Styles.RED);
    final result = StringBuffer();
    result.write(out);
    result.write(error);
    writeLine(result.toString());
  }

  void writeLine(String output) {
    write(output);
    endLine();
  }

  void endLine() {
    final sb = StringBuffer();
    _writeSpace(sb, 2*nIndent);

    for(var i = 0; i < cols.length; i++) {
      final col = cols[i];
      var req = col.width - col.length;
      if(i == 0) {
        req -= (2*nIndent);
      }
      if(col.alignment == AFOutputAlignment.alignRight) {
        _writeSpace(sb, req, fill: col.fill);
      }

      final out = _colorize(col.content.toString(), col.color);
      sb.write(out);
      
      if(col.alignment == AFOutputAlignment.alignLeft) {
        _writeSpace(sb, req, fill: col.fill);
      }
    }

    print(sb.toString());

    cols.clear();
  }

  void _writeSpace(StringBuffer sb, int count, { String fill = " "}) {
    for(var i = 0; i < count; i++) {
      sb.write(fill);
    }   
  }

}
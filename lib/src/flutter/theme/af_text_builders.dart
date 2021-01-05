import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/flutter/core/afui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


/// Used for building up RichText widgets in parts.
class AFRichTextBuilder {
  final AFFundamentalTheme theme;
  final AFWidgetID wid;
  final TextStyle styleBold;
  final TextStyle styleNormal;
  final TextStyle styleTapable;
  final TextStyle styleMuted;
  
  final spans = <TextSpan>[];

  AFRichTextBuilder({
    @required this.theme,
    this.wid,
    this.styleBold,
    this.styleNormal,
    this.styleTapable,
    this.styleMuted,
  });

  bool get isEmpty {
    return spans.length == 0;
  }

  bool get isNotEmpty {
    return spans.length > 0;
  }

  void insertNormal(int idx, dynamic idOrText) {
    final text = theme.translate(idOrText);
    spans.insert(idx, TextSpan(text: text, style: styleNormal));
  }

  void writeTapable(dynamic idOrText, TapGestureRecognizer recognizer) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: styleTapable, recognizer: recognizer));
  }

  void writeBold(dynamic idOrText) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: styleBold));
  }

  void writeMuted(dynamic idOrText) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: styleMuted));
  }

  void writeNormal(dynamic idOrText) {
    final text = theme.translate(idOrText);
    write(text);
  }

  void write(String text) {
    spans.add(TextSpan(text: text, style: styleNormal));
  }

  /// Creates a rich text widget with the specified content.
  Widget toRichText() {
    return RichText(
        key: AFUI.keyForWID(wid),
        text: TextSpan(
        children: spans
        
    ));
  }
}


/// Used for building up Text widgets in parts.
class AFTextBuilder {
  final AFFundamentalTheme theme;
  final AFWidgetID wid;
  final TextStyle style;
  final buffer = StringBuffer();

  AFTextBuilder({
    @required this.theme,
    this.wid,
    this.style
  });

  void write(dynamic idOrText) {
    final trans = theme.translate(idOrText);
    buffer.write(trans);
  }
  
  Widget create() {
    return Text(
      buffer.toString(),
      key: AFUI.keyForWID(wid),
      style: style
    );
  }
}

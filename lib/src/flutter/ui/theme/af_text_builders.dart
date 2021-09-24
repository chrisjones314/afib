import 'package:afib/src/dart/redux/state/af_theme_state.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


/// Used for building up RichText widgets in parts.
class AFRichTextBuilder {
  final AFFundamentalThemeState theme;
  final AFWidgetID? wid;
  final TextStyle? styleBold;
  final TextStyle? styleNormal;
  final TextStyle? styleTapable;
  final TextStyle? styleMuted;
  
  final spans = <InlineSpan>[];

  AFRichTextBuilder({
    required this.theme,
    this.wid,
    this.styleBold,
    this.styleNormal,
    this.styleTapable,
    this.styleMuted,
  });

  bool get isEmpty {
    return spans.isEmpty;
  }

  bool get isNotEmpty {
    return spans.isNotEmpty;
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

  void writeWidget(Widget widget) {
    spans.add(WidgetSpan(child: widget));
  }

  void writeStyled(dynamic idOrText, TextStyle style) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: style));
  }

  void writeNormal(dynamic idOrText) {
    final text = theme.translate(idOrText);
    write(text);
  }

  void write(String text) {
    spans.add(TextSpan(text: text, style: styleNormal));
  }

  /// Creates a rich text widget with the specified content.
  Widget toRichText({
    TextAlign textAlign = TextAlign.start,
  }) {
    return RichText(
        key: AFFunctionalTheme.keyForWIDStatic(wid),
        textAlign: textAlign,
        text: TextSpan(
        children: spans
        
    ));
  }
}


/// Used for building up Text widgets in parts.
class AFTextBuilder {
  final AFFundamentalThemeState theme;
  final AFWidgetID? wid;
  final TextStyle? style;
  final buffer = StringBuffer();

  AFTextBuilder({
    required this.theme,
    this.wid,
    this.style
  });

  bool get isEmpty {
    return buffer.isEmpty;
  }

  void write(dynamic idOrText) {
    final trans = theme.translate(idOrText);
    buffer.write(trans);
  }
  
  Widget create() {
    return Text(
      buffer.toString(),
      key: AFFunctionalTheme.keyForWIDStatic(wid),
      style: style
    );
  }
}

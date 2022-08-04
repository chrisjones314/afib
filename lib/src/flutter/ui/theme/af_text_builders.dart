import 'package:afib/src/dart/redux/state/models/af_theme_state.dart';
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
  int markPoint = -1;

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

  void mark() {
    markPoint = spans.length;
  }

  void insertNormal(int idx, dynamic idOrText, {
    GestureRecognizer? onGesture
  }) {
    final text = theme.translate(idOrText);
    spans.insert(idx, TextSpan(text: text, style: styleNormal, recognizer: onGesture));
  }

  void writeTapable(dynamic idOrText, GestureRecognizer? recognizer) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: styleTapable, recognizer: recognizer));
  }

  void writeBold(dynamic idOrText, {
    GestureRecognizer? onGesture
  }) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: styleBold));
  }

  void writeMuted(dynamic idOrText, {
    GestureRecognizer? onGesture
  }) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: styleMuted, recognizer: onGesture));
  }

  void writeWidget(Widget widget) {
    spans.add(WidgetSpan(child: widget));
  }

  void writeStyled(dynamic idOrText, TextStyle? style, {
    GestureRecognizer? onGesture
  }) {
    final text = theme.translate(idOrText);
    spans.add(TextSpan(text: text, style: style, recognizer: onGesture));
  }

  void writeIfNonEmpty(dynamic idOrText, {
    TextStyle? style,
    GestureRecognizer? onGesture
  }) {
    if(isNotEmpty) {
      final text = theme.translate(idOrText);
      spans.add(TextSpan(text: text, style: style, recognizer: onGesture));
    }
  }

  bool get isAtMark {
    return markPoint == spans.length;
  }

  void writeIfAtMark(dynamic idOrText, {
    TextStyle? style,
    GestureRecognizer? onGesture
  }) {
    if(markPoint == spans.length) {
      final text = theme.translate(idOrText);
      spans.add(TextSpan(text: text, style: style, recognizer: onGesture));
    }
  }


  void writeIfPastMark(dynamic idOrText, {
    TextStyle? style,
    GestureRecognizer? onGesture
  }) {
    if(markPoint < spans.length) {
      final text = theme.translate(idOrText);
      spans.add(TextSpan(text: text, style: style, recognizer: onGesture));
    }
  }

  void writeNormal(dynamic idOrText) {
    final text = theme.translate(idOrText);
    write(text);
  }

  void write(String text) {
    spans.add(TextSpan(text: text, style: styleNormal));
  }

  String toSimpleText() {
    final result = StringBuffer();
    for(final span in spans) {
      if(span is TextSpan) {
        final text = span.text;
        if(text != null) {
          result.write(text);
        }
      }
    }
    return result.toString();
  }

  /// Creates a rich text widget with the specified content.
  Widget toRichText({
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines = 10,
    bool softWrap = true,
  }) {
    return RichText(
        key: AFFunctionalTheme.keyForWIDStatic(wid),
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
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

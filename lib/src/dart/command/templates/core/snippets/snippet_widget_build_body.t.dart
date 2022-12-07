
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetWidgetBuildBodyT extends AFCoreSnippetSourceTemplate {
  String get template => '''
    final t = spi.t;
    return t.childText("${insertMainType.spaces}");
''';
}

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetBuildBodyImplT extends AFSourceTemplate {
  final String template = '''
    final t = spi.t;
    return t.childText("[!af_screen_name]");
''';
}
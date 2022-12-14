
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetInitialStateModelFunctionT extends AFCoreSnippetSourceTemplate {
  String get template => '''
static $insertMainType initialState() {
  return $insertMainType();
}
''';
}

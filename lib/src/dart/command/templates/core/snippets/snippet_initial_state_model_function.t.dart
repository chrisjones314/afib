
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';

class SnippetInitialStateModelFunctionT extends AFCoreSnippetSourceTemplate {
  String get template => '''
static $insertMainType initialState() {
  return $insertMainType();
}
''';
}

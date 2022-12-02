
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/model.t.dart';

class SnippetInitialStateModelFunctionT extends AFSnippetSourceTemplate {
  String get template => '''
static ${ModelT.insertModelName} initialState() {
  return ${ModelT.insertModelName}();
}
''';
}

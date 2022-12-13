
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class SnippetWireframeBodyT extends AFCoreSnippetSourceTemplate {
  SnippetWireframeBodyT(): super(templateFileId: "wireframe_body");

  @override
  String get template => '''
bool _executeHandleEvent${UnitTestT.insertTestName}Wireframe(AFWireframeExecutionContext context) {
  return false;
}
''';
}

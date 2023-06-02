import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetUnitTestImplT extends AFCoreSnippetSourceTemplate {
  SnippetUnitTestImplT(): super(templateFileId: "unit_test_impl");

  @override
  String get template => '''
e.expect(10, ft.equals(10));
''';
}




import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetUnitTestImplT extends AFCoreSnippetSourceTemplate {
  SnippetUnitTestImplT(): super(templateFileId: "unit_test_impl");

  String get template => '''
e.expect(10, ft.equals(10));
''';
}

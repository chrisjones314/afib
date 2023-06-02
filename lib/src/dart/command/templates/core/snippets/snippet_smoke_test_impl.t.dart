import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetSmokeTestImplT extends AFCoreSnippetSourceTemplate {

  SnippetSmokeTestImplT(): super(templateFileId: "smoke_test_impl");
  
  @override
  String get template => "";
}

class SnippetSmokeTestImplRequireCloseT extends AFCoreSnippetSourceTemplate {

  SnippetSmokeTestImplRequireCloseT(): super(templateFileId: "smoke_test_impl");
  
  @override
  String get template => '''
/// IMPORTANT: Failing to close your dialog/bottomsheet/drawer at the end of your test
/// will leave it open, and will lead to confusing errors in command-line UI tests.
await e.applyTap(${insertAppNamespaceUpper}WidgetID.standardClose);
''';
}

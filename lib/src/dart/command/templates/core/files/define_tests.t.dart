
import 'package:afib/src/dart/command/af_source_template.dart';

class DefineTestsT extends AFCoreFileSourceTemplate {
  static const insertTestKind = AFSourceTemplateInsertion("test_kind");
  
  DefineTestsT(): super(
    templateFileId: "define_tests",
  );

  final String template = '''
import 'package:afib/afib_flutter.dart';

void define${insertTestKind}s(AF${insertTestKind}DefinitionContext context) {
}
''';
}

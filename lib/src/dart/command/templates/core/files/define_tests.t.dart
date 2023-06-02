
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class DefineTestsT extends AFCoreFileSourceTemplate {
  static const insertTestKind = AFSourceTemplateInsertion("test_kind");
  
  DefineTestsT(): super(
    templateFileId: "define_tests",
  );

  @override
  final String template = '''
import 'package:afib/afib_flutter.dart';

void define${insertTestKind}s(AF${insertTestKind}DefinitionContext context) {
}
''';
}

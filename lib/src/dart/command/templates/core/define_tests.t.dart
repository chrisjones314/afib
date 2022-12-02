
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class DefineTestsT extends AFFileSourceTemplate {
  static const insertTestKind = AFSourceTemplateInsertion("test_kind");
  
  DefineTestsT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "define_tests"],
  );

  final String template = '''
import 'package:afib/afib_flutter.dart';

void define${insertTestKind}s(AF${insertTestKind}DefinitionContext context) {
}
''';
}

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class LPIT extends AFFileSourceTemplate {

  LPIT({
    required String templateFileId,
    required List<String> templateFolder,
    required Object insertExtraImports,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: insertExtraImports,
      AFSourceTemplate.insertAdditionalMethodsInsertion: insertAdditionalMethods,
    }),
  );  

  factory LPIT.core() {
    return LPIT(
      templateFileId: "lpi",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      insertExtraImports: AFSourceTemplate.empty,
      insertAdditionalMethods: AFSourceTemplate.empty,
    );
  }

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
$insertExtraImports

class $insertMainType extends $insertMainParentType {

  $insertMainType(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context): super(id, context);

  factory $insertMainType.create(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context) {
    return $insertMainType(id, context);
  }

  $insertAdditionalMethods
}
''';

}







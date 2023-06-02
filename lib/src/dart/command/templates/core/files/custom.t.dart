
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class CustomT extends AFFileSourceTemplate {

  CustomT({
    required String templateFileId,
    required List<String> templateFolder,
    AFSourceTemplateInsertions? embeddedInsertions,     
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

  factory CustomT.core() {
    return CustomT(
      templateFileId: "custom",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,        
      })
    );
  }

  String get template => '''
$insertExtraImports

$insertAdditionalMethods
  ''';
}
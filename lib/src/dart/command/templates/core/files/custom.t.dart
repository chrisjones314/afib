
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class CustomT extends AFFileSourceTemplate {

  CustomT({
    required super.templateFileId,
    required super.templateFolder,
    super.embeddedInsertions,     
  });

  factory CustomT.core() {
    return CustomT(
      templateFileId: "custom",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,        
      })
    );
  }

  @override
  String get template => '''
$insertExtraImports

$insertAdditionalMethods
  ''';
}
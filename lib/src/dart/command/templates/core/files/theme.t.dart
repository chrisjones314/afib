import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class ThemeT extends AFFileSourceTemplate {

  ThemeT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });  

  factory ThemeT.core() {
    return ThemeT(
      templateFileId: "theme",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
      })
    );
  } 

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
$insertExtraImports

class $insertMainType extends $insertMainParentType {
  $insertMainType(AFThemeID id, AFFundamentalThemeState fundamentals, AFBuildContext context): super(id, fundamentals, context);

  factory $insertMainType.create(AFThemeID id, AFFundamentalThemeState fundamentals, AFBuildContext context) {
    return $insertMainType(id, fundamentals, context);
  }

  $insertAdditionalMethods
}

''';
}

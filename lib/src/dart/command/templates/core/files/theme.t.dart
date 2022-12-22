import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ThemeT extends AFFileSourceTemplate {

  ThemeT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );  

  factory ThemeT.core() {
    return ThemeT(
      templateFileId: "theme",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
      })
    );
  } 

  String get template => '''
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


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';

class ModelSigninUserT extends ModelT {
  
  ModelSigninUserT({
    required super.templateFileId,
    required super.templateFolder,
    super.embeddedInsertions,
  });  

  factory ModelSigninUserT.custom({
    required List<String> templateFolder,
    required Object extraImports,
    required Object additionalMethods, 
  }) {
    return ModelSigninUserT(
      templateFileId: "model_user",
      templateFolder: templateFolder,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: extraImports,
      AFSourceTemplate.insertAdditionalMethodsInsertion: additionalMethods
    }));

  }

  factory ModelSigninUserT.example() {
    return ModelSigninUserT.custom(
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
      extraImports: '''
''', 
      additionalMethods: '''
String get fullName => "\$firstName \$lastName";
''',
    );
  }
}


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ModelT extends AFFileSourceTemplate {
  
  ModelT({
    required List<String> templateFolder,
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelT.core() {
    return ModelT(
      templateFolder: AFProjectPaths.pathGenerateCoreFiles, 
      templateFileId: "model",
      embeddedInsertions: AFSourceTemplateInsertions(
      insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertMemberVariablesInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertConstructorParamsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertCopyWithParamsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertCopyWithCallInsertion: AFSourceTemplate.empty,      
    }));
  }


  String get template => '''
import 'package:meta/meta.dart';
$insertExtraImports

@immutable
class $insertMainType {
  $insertMemberVariables

  $insertMainType($insertConstructorParams);

  $insertAdditionalMethods

  $insertMainType copyWith($insertCopyWithParams) {
    return $insertMainType($insertCopyWithConstructorCall);
  }
}
''';
}

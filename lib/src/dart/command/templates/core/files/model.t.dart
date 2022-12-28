

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ModelT extends AFFileSourceTemplate {
  static const insertSerialConstantsInsertion = AFSourceTemplateInsertion("serial_constants");
  static const insertSerialMethodsInsertion = AFSourceTemplateInsertion("serial_methods");
  
  ModelT({
    required List<String> templateFolder,
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelT.core({
    Object? memberVariables,
    Object? constructorParams,
    Object? copyWithParams,
    Object? copyWithCall,
    Object? serialMethods,
    Object? serialConstants,
    Object? memberVariableImports,
  }) {
    return ModelT(
      templateFolder: AFProjectPaths.pathGenerateCoreFiles, 
      templateFileId: "model",
      embeddedInsertions: AFSourceTemplateInsertions(
      insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertMemberVariablesInsertion: memberVariables ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertConstructorParamsInsertion: constructorParams ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertCopyWithParamsInsertion: copyWithParams ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertCopyWithCallInsertion: copyWithCall ?? AFSourceTemplate.empty,      
        insertSerialConstantsInsertion: serialConstants ?? AFSourceTemplate.empty,
        insertSerialMethodsInsertion: serialMethods ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertMemberVariableImportsInsertion: memberVariableImports ?? AFSourceTemplate.empty,
    }));
  }


  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:meta/meta.dart';
$insertExtraImports
$insertMemberVariableImports

@immutable
class $insertMainType {
  $insertSerialConstantsInsertion
  $insertMemberVariables

  $insertMainType($insertConstructorParams);

  $insertAdditionalMethods

  $insertMainType copyWith($insertCopyWithParams) {
    return $insertMainType($insertCopyWithConstructorCall);
  }

  $insertSerialMethodsInsertion
}
''';
}

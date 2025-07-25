

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class ModelT extends AFFileSourceTemplate {
  static const templateIdModel = "model";
  static const templateIdModelRoot = "model_root";
  static const insertSerialConstantsInsertion = AFSourceTemplateInsertion("serial_constants");
  static const insertSerialMethodsInsertion = AFSourceTemplateInsertion("serial_methods");
  static const insertReviseMethods = AFSourceTemplateInsertion("revise_methods");
  static const insertSuperclassSyntax = AFSourceTemplateInsertion("superclass_syntax");
  static const insertStandardRootMethods = AFSourceTemplateInsertion("root_methods");
  static const insertSuperCall = AFSourceTemplateInsertion("super_call");
  static const insertResolveMethods = AFSourceTemplateInsertion("resolve_methods");
  static const insertInitialState = AFSourceTemplateInsertion("initial_state");
  
  ModelT({
    required super.templateFolder,
    required super.templateFileId,
    super.embeddedInsertions,
  });

  factory ModelT.core({
    required bool isRoot,
    Object? memberVariables,
    Object? constructorParams,
    Object? copyWithParams,
    Object? copyWithCall,
    Object? serialMethods,
    Object? serialConstants,
    Object? memberVariableImports,
    Object? standardReviseMethods,
    Object? standardRootMethods,
    Object? superclassSyntax,
    Object? superCall,
    Object? resolveFunctions,
    Object? additionalMethods,
  }) {
    return ModelT(
      templateFolder: AFProjectPaths.pathGenerateCoreFiles, 
      templateFileId: isRoot ? templateIdModelRoot : templateIdModel,
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
        insertReviseMethods: standardReviseMethods ?? AFSourceTemplate.empty,
        insertStandardRootMethods: standardRootMethods ?? AFSourceTemplate.empty,
        insertSuperclassSyntax: superclassSyntax ?? AFSourceTemplate.empty,
        insertSuperCall: superCall ?? AFSourceTemplate.empty,
        insertResolveMethods: resolveFunctions ?? AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: additionalMethods ?? AFSourceTemplate.empty,
    }));
  }


  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:meta/meta.dart';
$insertExtraImports
$insertMemberVariableImports

// ignore_for_file: unused_import

@immutable
class $insertMainType $insertSuperclassSyntax {
  $insertSerialConstantsInsertion
  $insertMemberVariables

  // ignore: prefer_const_constructors_in_immutables
  $insertMainType($insertConstructorParams)$insertSuperCall;

  $insertInitialState
  $insertResolveMethods
  $insertReviseMethods
  $insertStandardRootMethods
  $insertAdditionalMethods

  $insertMainType copyWith($insertCopyWithParams) {
    return $insertMainType($insertCopyWithConstructorCall);
  }

  $insertSerialMethodsInsertion
}
''';
}

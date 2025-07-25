import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class ScreenTestT extends AFCoreFileSourceTemplate {
  static const insertDeclarePrototype = AFSourceTemplateInsertion("declare_prototype");
  static const insertSmokeTestImpl = AFSourceTemplateInsertion("smoke_test_impl");

  ScreenTestT({
    required super.templateFileId,
    super.embeddedInsertions,
  });  

  factory ScreenTestT.core() {
    return ScreenTestT(
      templateFileId: "screen_test",      
    );
  }

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
$insertExtraImports

// ignore_for_file: depend_on_referenced_packages, unused_import

void define${insertMainType}Prototypes(AFUIPrototypeDefinitionContext context) {
  _define${insertMainType}PrototypeInitial(context);
}

void _define${insertMainType}PrototypeInitial(AFUIPrototypeDefinitionContext context) {  
  $insertDeclarePrototype

  prototype.defineSmokeTest( 
    body: (e) async {
      $insertSmokeTestImpl
  });
}
''';
}

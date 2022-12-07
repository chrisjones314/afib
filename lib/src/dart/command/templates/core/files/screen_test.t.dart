import 'package:afib/src/dart/command/af_source_template.dart';

class ScreenTestT extends AFCoreFileSourceTemplate {
  static const insertDeclarePrototype = AFSourceTemplateInsertion("declare_prototype");
  static const insertSmokeTestImpl = AFSourceTemplateInsertion("smoke_test_impl");

  ScreenTestT({
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    embeddedInsertions: embeddedInsertions,
  );  

  factory ScreenTestT.core() {
    return ScreenTestT(
      templateFileId: "screen_test",      
    );
  }

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

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

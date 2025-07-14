import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class StateTestT extends AFFileSourceTemplate {
  static const insertExtendTestId = AFSourceTemplateInsertion("extend_test_id");

  StateTestT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });  

  factory StateTestT.core() {
    return StateTestT(
      templateFileId: "state_test",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
      })
    );
  } 

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/${insertAppNamespace}_id.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/test/${AFSourceTemplate.insertAppNamespaceInsertion}_state_test_shortcuts.dart';
$insertExtraImports

// ignore_for_file: depend_on_referenced_packages, unused_import

void define${UnitTestT.insertTestName}StateTest(AFStateTestDefinitionContext definitions) {

  definitions.addTest(${insertAppNamespaceUpper}StateTestID.${UnitTestT.insertTestName.camel}, extendTest: $insertExtendTestId, body: (testContext) {
    ${UnitTestT.insertUnitTestCode}
  });

}
''';
}

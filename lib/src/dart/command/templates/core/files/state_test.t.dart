import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class StateTestT extends AFFileSourceTemplate {
  static const insertExtendTestId = AFSourceTemplateInsertion("extend_test_id");

  StateTestT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );  

  factory StateTestT.core() {
    return StateTestT(
      templateFileId: "state_test",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
      })
    );
  } 

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/${insertAppNamespace}_id.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/test/${AFSourceTemplate.insertAppNamespaceInsertion}_state_test_shortcuts.dart';
$insertExtraImports

void define${UnitTestT.insertTestName}StateTest(AFStateTestDefinitionContext definitions) {

  definitions.addTest(${insertAppNamespaceUpper}StateTestID.${UnitTestT.insertTestName.camel}, extendTest: $insertExtendTestId, body: (testContext) {
    ${UnitTestT.insertUnitTestCode}
  });

}
''';
}

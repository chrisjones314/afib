import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class UnitTestT extends AFFileSourceTemplate {
  static const insertTestName = AFSourceTemplateInsertion("test_name");
  static const insertUnitTestCode = AFSourceTemplateInsertion("unit_test_code");

  UnitTestT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );  

  factory UnitTestT.core() {
    return UnitTestT(
      templateFileId: "unit_test",
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
$insertExtraImports

// ignore_for_file: depend_on_referenced_packages, unused_import

void define${insertTestName}UnitTest(AFUnitTestDefinitionContext definitions) {

  definitions.defineTest(${insertAppNamespaceUpper}UnitTestID.${insertTestName.camel}, (e) {
    $insertUnitTestCode
  });

}
''';
}

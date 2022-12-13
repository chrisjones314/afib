import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class WireframeT extends AFFileSourceTemplate {

  WireframeT({
    required String templateFileId,
    required List<String> templateFolder,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
  );  

  factory WireframeT.core() {
    return WireframeT(
      templateFileId: "wireframe",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  } 

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/${insertAppNamespace}_id.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
$insertExtraImports

void define${UnitTestT.insertTestName}Wireframe(AFWireframeDefinitionContext definitions) {

  ${UnitTestT.insertUnitTestCode}
}

$insertAdditionalMethods

''';
}

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class WireframeT extends AFFileSourceTemplate {

  WireframeT({
    required super.templateFileId,
    required super.templateFolder,
  });  

  factory WireframeT.core() {
    return WireframeT(
      templateFileId: "wireframe",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  } 

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/${insertAppNamespace}_id.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
$insertExtraImports

// ignore_for_file: depend_on_referenced_packages, unused_import

void define${UnitTestT.insertTestName}Wireframe(AFWireframeDefinitionContext definitions) {

  ${UnitTestT.insertUnitTestCode}
}

$insertAdditionalMethods

''';
}

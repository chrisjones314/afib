
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class SnippetWireframeImplT extends AFSnippetSourceTemplate {
  static const insertInitialScreen = AFSourceTemplateInsertion("initial_screen");
  static const insertNavPushParams = AFSourceTemplateInsertion("nav_push_params");

  SnippetWireframeImplT({
    required super.templateFileId,
    required super.templateFolder,
    Object? navPushParams,
  }): super(
    embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      SnippetWireframeImplT.insertNavPushParams: navPushParams ?? AFSourceTemplate.empty,
    }),
  );

  factory SnippetWireframeImplT.core() {
    return SnippetWireframeImplT(
      templateFileId: "wireframe_impl",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
    );
  }

  @override
  List<String> get extraImports {
    return [
      "import 'package:$insertPackagePath/ui/screens/${insertInitialScreen.snake}.dart';",
    ];
  }

  @override
  String get template => '''
definitions.defineWireframe(
  id: ${insertAppNamespaceUpper}WireframeID.${UnitTestT.insertTestName.camel},
  navigate: $insertInitialScreen.navigatePush($insertNavPushParams),
  stateView: [${insertAppNamespaceUpper}TestDataID.${insertAppNamespace}StateFullLogin, AFTimeState.createNow()],
  body: _executeHandleEvent${UnitTestT.insertTestName}Wireframe,
  enableUINavigation: true,
  timeHandling: AFTestTimeHandling.running
);
''';
}


import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class SnippetWireframeImplT extends AFCoreSnippetSourceTemplate {
  static const insertInitialScreen = AFSourceTemplateInsertion("initial_screen");

  SnippetWireframeImplT(): super(templateFileId: "wireframe_impl");

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
  navigate: $insertInitialScreen.navigatePush(),
  stateView: [${insertAppNamespaceUpper}TestDataID.${insertAppNamespace}StateFullLogin, AFTimeState.createNow()],
  body: _executeHandleEvent${UnitTestT.insertTestName}Wireframe,
  enableUINavigation: true,
  timeHandling: AFTestTimeHandling.running
);
''';
}

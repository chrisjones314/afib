
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';

class SnippetInitialWireframeBodyT extends AFSnippetSourceTemplate {
  SnippetInitialWireframeBodyT(): super(
    templateFileId: "initial_wireframe_body",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );

  @override
  List<String> get extraImports => [   
      "import 'package:$insertPackagePath/ui/screens/counter_management_screen.dart';",
      "import 'package:$insertPackagePath/state/stateviews/${insertAppNamespace}_default_state_view.dart';",
      "import 'package:$insertPackagePath/state/models/count_history_entry.dart';",
      "import 'package:$insertPackagePath/state/root/count_history_root.dart';",

  ];
  
  String get template => '''
bool _executeHandleEvent${UnitTestT.insertTestName}Wireframe(AFWireframeExecutionContext context) {
  final stateView = context.accessStateView<${insertAppNamespaceUpper}DefaultStateView>();

  if(context.isScreenAndWidget(${insertAppNamespaceUpper}ScreenID.counterManagement, ${insertAppNamespaceUpper}WidgetID.buttonSaveTransientCount)) {
    final param = context.accessEventParam<CounterManagementScreenRouteParam>();
    final countHistory = stateView.countHistory;
    final revised = countHistory.reviseAddEntry(
      CountHistoryEntry.createNew(
        count: param.clickCount, 
        userId: stateView.userCredential.userId,
        idPrefix: "count_wireframe"
      )
    );
    context.updateStateViewRootOne(revised);
    return true;
  }  else if(context.isScreenAndWidget(${AFSourceTemplate.insertAppNamespaceInsertion.upper}ScreenID.counterManagement, ${AFSourceTemplate.insertAppNamespaceInsertion.upper}WidgetID.buttonResetHistory)) {
    context.updateStateViewRootOne(CountHistoryRoot.initialState());
    return true;
  }
  return false;
}
''';
}

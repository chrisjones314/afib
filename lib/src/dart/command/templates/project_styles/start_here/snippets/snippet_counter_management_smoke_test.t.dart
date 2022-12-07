

import 'package:afib/afib_command.dart';

class SnippetCounterManagementSmokeTest extends AFSnippetSourceTemplate {

  SnippetCounterManagementSmokeTest(): super(
    templateFileId: "counter_management_smoke_test",
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );

  String get template => '''
      await e.matchText(${insertAppNamespaceUpper}WidgetID.textCountRouteParam, ft.equals("3"));
      await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam);
      await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam);
      await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam);
      await e.matchText(${insertAppNamespaceUpper}WidgetID.textCountRouteParam, ft.equals("6"));
''';

}



import 'package:afib/afib_command.dart';

class SnippetHomeScreenSmokeTest extends AFSnippetSourceTemplate {

  SnippetHomeScreenSmokeTest(): super(
    templateFileId: "home_screen_smoke_test",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );

  @override
  List<String> get extraImports => [
  "import 'package:$insertPackagePath/ui/screens/home_page_screen.dart';"
];

  @override
  String get template => '''
await e.matchText(${insertAppNamespaceUpper}WidgetID.textCurrentStanza, ft.contains("that a single man"));
await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIHaveNoObjection, verify: (verifyContext) {
  final routeParam = verifyContext.accessRouteParamUpdate<HomePageScreenRouteParam>();
  e.expect(routeParam.lineNumber, ft.equals(1));
});
await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonManageCount, verify: (verifyContext) {
  final nav = verifyContext.accessOneAction<AFNavigatePushAction>();
  e.expect(nav.screenId, ft.equals(${insertAppNamespaceUpper}ScreenID.counterManagement));
});

''';

}

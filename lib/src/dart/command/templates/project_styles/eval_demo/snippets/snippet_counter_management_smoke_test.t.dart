

import 'package:afib/afib_command.dart';

class SnippetCounterManagementSmokeTest extends AFSnippetSourceTemplate {

  SnippetCounterManagementSmokeTest(): super(
    templateFileId: "counter_management_smoke_test",
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );

  @override
  List<String> get extraImports => [
  "import 'package:$insertPackagePath/query/simple/write_count_history_entry_query.dart';"
];

  String get template => '''
await e.matchText(${insertAppNamespaceUpper}WidgetID.textCountRouteParam, ft.equals("0"));
await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam);
await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam);
await e.applyTap(${insertAppNamespaceUpper}WidgetID.buttonIncrementRouteParam);
await e.matchText(${insertAppNamespaceUpper}WidgetID.textCountRouteParam, ft.equals("3"));

await e.applyTap(HCWidgetID.buttonSaveTransientCount, verify: (verifyContext) {
  final write = verifyContext.accessOneQuery<WriteCountHistoryEntryQuery>();
  e.expect(write.entry.count, ft.equals(3));
});

''';

}

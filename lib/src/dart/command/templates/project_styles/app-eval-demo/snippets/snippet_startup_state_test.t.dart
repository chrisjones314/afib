import 'package:afib/afib_command.dart';

class SnippetStartupStateTestT extends AFSnippetSourceTemplate {

  SnippetStartupStateTestT(): super(
    templateFileId: 'startup_state_test',
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
  );

  @override
  List<String> get extraImports {
    return [
"import 'package:$insertPackagePath/query/simple/read_count_history_query.dart';",
"import 'package:$insertPackagePath/query/simple/read_user_query.dart';",
"import 'package:$insertPackagePath/query/simple/startup_query.dart';",
"import 'package:$insertPackagePath/query/simple/check_signin_query.dart';",
"import 'package:$insertPackagePath/query/simple/write_count_history_item_query.dart';",
"import 'package:$insertPackagePath/state/models/count_history_item.dart';",
"import 'package:$insertPackagePath/test/${insertAppNamespace}_state_test_shortcuts.dart';",
"import 'package:$insertPackagePath/query/simple/reset_history_query.dart';",
"import 'package:$insertPackagePath/state/root/count_history_items_root.dart';",

    ];
  }

  @override
  String get template => '''
testContext.defineInitialTime(AFTimeState.createNow());
testContext.defineQueryResponseUnused<StartupQuery>();
testContext.defineQueryResponseFixed<CheckSigninQuery>(${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast);
testContext.defineQueryResponseFixed<ReadUserQuery>(${insertAppNamespaceUpper}TestDataID.userWestCoast);
testContext.defineQueryResponseFixed<ReadCountHistoryQuery>(${insertAppNamespaceUpper}TestDataID.countHistoryWestCoast);
testContext.defineQueryResponseFixed<ResetHistoryQuery>(CountHistoryItemsRoot.initialState());
testContext.defineQueryResponseDynamic<WriteCountHistoryItemQuery>(body: (context, query) {
    final entry = query.item;
    CountHistoryItem result;
    if(AFDocumentIDGenerator.isNewId(entry.id)) {
      result = entry.copyWith(id: AFDocumentIDGenerator.createTestIdIncreasing("count_statetest"));
    } else {
      result = entry.copyWith();
    }
    context.onSuccess(result);
});

testContext.executeStartup();

final shortcuts = ${insertAppNamespaceUpper}StateTestShortcuts(testContext);
final homeScreen = shortcuts.createHomePageScreen();
final counterScreen = shortcuts.createCounterManagementScreen();
const firstStanza = "that a single man";
const secondStanza = "must be in want";

homeScreen.executeScreen((e, screenContext) {
  screenContext.executeBuild((spi) { 
    e.expect(spi.textCurrentStanza, ft.contains(firstStanza));
    spi.onPressedIHaveNoObjection();
  });

  screenContext.executeBuild((spi) { 
    e.expect(spi.textCurrentStanza, ft.contains(secondStanza));
    e.expect(spi.clickCountState, ft.equals(7));
    spi.onPressedManageCount();
  });
});

counterScreen.executeScreen((e, screenContext) { 
  screenContext.executeBuild((spi) { 
    e.expect(spi.clickCountParam, ft.equals(0));
    e.expect(spi.clickCountState, ft.equals(7));
    spi.onPressedIncrementTransientCount();
  });
  screenContext.executeBuild((spi) { 
    spi.onPressedIncrementTransientCount();
  });
  screenContext.executeBuild((spi) { 
    spi.onPressedIncrementTransientCount();
  });

  screenContext.executeBuild((spi) { 
    e.expect(spi.clickCountParam, ft.equals(3));
    spi.onPressedPersistTransientCount();
  });

  screenContext.executeBuild((spi) { 
    e.expect(spi.clickCountState, ft.equals(10));
    spi.onPressedStandardBackButton();
  });
});

homeScreen.executeScreenBuild((e, spi) { 
  e.expect(spi.textCurrentStanza, ft.contains(secondStanza));
  e.expect(spi.clickCountState, ft.equals(10));
});
''';
}
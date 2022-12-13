

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetStartupStateTestT extends AFSnippetSourceTemplate {

  SnippetStartupStateTestT(): super(
    templateFileId: 'startup_state_test',
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
  );

  @override
  List<String> get extraImports {
    return [
"import 'package:$insertPackagePath/query/simple/read_count_in_state_query.dart';",
"import 'package:$insertPackagePath/query/simple/read_referenced_user_query.dart';",
"import 'package:$insertPackagePath/query/simple/startup_query.dart';",
"import 'package:$insertPackagePath/query/simple/write_count_history_entry_query.dart';",
"import 'package:$insertPackagePath/state/models/count_history_entry.dart';",
"import 'package:$insertPackagePath/test/${insertAppNamespace}_state_test_shortcuts.dart';",
    ];
  }

  @override
  String get template => '''
testContext.defineQueryResponseFixed<StartupQuery>(${insertAppNamespaceUpper}TestDataID.userCredentialChris);
testContext.defineQueryResponseFixed<ReadReferencedUserQuery>(${insertAppNamespaceUpper}TestDataID.referencedUserChris);
testContext.defineQueryResponseFixed<ReadCountInStateQuery>(${insertAppNamespaceUpper}TestDataID.countHistoryChris);
testContext.defineQueryResponseDynamic<WriteCountHistoryEntryQuery>(body: (context, query) {
    final entry = query.entry;
    CountHistoryEntry result;
    if(AFDocumentIDGenerator.isNewId(entry.id)) {
      result = entry.copyWith(id: AFDocumentIDGenerator.createTestIdIncreasing("count_statetest"));
    } else {
      result = entry.copyWith();
    }
    return result;
});

testContext.executeStartup();

final shortcuts = ${insertAppNamespaceUpper}StateTestShortcuts(testContext);
final homeScreen = shortcuts.createHomePageScreenScreen();
final counterScreen = shortcuts.createCounterManagementScreenScreen();
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
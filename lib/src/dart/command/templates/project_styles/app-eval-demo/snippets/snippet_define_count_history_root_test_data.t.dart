

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineCountHistoryRootTestDataT extends SnippetDefineTestDataT {
  
  SnippetDefineCountHistoryRootTestDataT(): super(
      templateFileId: "define_count_history_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: '''
final countWestCoast = CountHistoryItemsRoot.fromList([
  CountHistoryItem(id: "__test_1", userId: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userWestCoast, count: 4),
  CountHistoryItem(id: "__test_2", userId: ${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.userWestCoast, count: 3),
]);

// feel its a little less confusing if the example state test refers to a more natural ID.
context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.countHistoryWestCoast, countWestCoast);
''',
        SnippetDefineTestDataT.insertModelCall: "countWestCoast"
      })
  );

  @override 
  List<String> get extraImports {
    return [
      "import 'package:$insertPackagePath/state/models/count_history_item.dart';"
    ];
  }

  static SnippetDefineTestDataT example() {
    return SnippetDefineCountHistoryRootTestDataT();
  }
}

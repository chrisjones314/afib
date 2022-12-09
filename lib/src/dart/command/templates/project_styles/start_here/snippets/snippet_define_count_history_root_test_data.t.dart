

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';

class SnippetDefineCountHistoryRootTestDataT extends SnippetDefineTestDataT {
  
  SnippetDefineCountHistoryRootTestDataT(): super(
      templateFileId: "define_count_history_root_test_data",
      templateFolder: AFProjectPaths.pathGenerateExampleStartHereSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: '''
final countChris = CountHistoryRoot.fromList([
  CountHistoryEntry(id: "__test_1", count: 4),
  CountHistoryEntry(id: "__test_2", count: 3),
]);

// feel its a little less confusing if the example state test refers to a more natural ID.
context.define(${AFSourceTemplate.insertAppNamespaceInsertion.upper}TestDataID.countHistoryChris, countChris);
''',
        SnippetDefineTestDataT.insertModelCall: "countChris"
      })
  );

  @override 
  List<String> get extraImports {
    return [
      "import 'package:$insertPackagePath/state/models/count_history_entry.dart';"
    ];
  }

  static SnippetDefineTestDataT example() {
    return SnippetDefineCountHistoryRootTestDataT();
  }
}



import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_example_start_here.t.dart';

class QueryResetHistoryT extends QueryExampleStartHereT {
  QueryResetHistoryT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_reset_history",
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryResetHistoryT.example() {
    return QueryResetHistoryT(
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/count_history_items_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_item.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
''',
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();

final uid = int.tryParse(userId);
db.execute("delete from \${CountHistoryItem.tableName} where \${CountHistoryItem.colUserId} = ?", [uid]);
context.onSuccess(CountHistoryItemsRoot.initialState());
''',
      insertFinishImpl: '''
// reset the history to empty.
final response = context.r;
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(response);
''',
      insertAdditionalMethods: AFSourceTemplate.empty,
    );
  }



  
}
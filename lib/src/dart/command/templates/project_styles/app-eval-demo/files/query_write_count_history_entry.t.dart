

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_example_start_here.t.dart';

class QueryWriteCountHistoryItemT extends QueryExampleStartHereT {
  QueryWriteCountHistoryItemT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_write_count_history_item",
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: AFSourceTemplate.empty,
  );

  factory QueryWriteCountHistoryItemT.example() {
    return QueryWriteCountHistoryItemT(
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_item.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''',
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();
final uid = int.tryParse(item.userId);
db.select("INSERT INTO \${CountHistoryItem.tableName} (\${CountHistoryItem.colUserId}, \${CountHistoryItem.colCount}) VALUES (?, ?)", [uid, item.count]);
final revised = item.reviseId(db.lastInsertRowId.toString());
context.onSuccess(revised);
''',
      insertFinishImpl: '''
final item = context.r;
final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
final history = ${AFSourceTemplate.insertAppNamespaceInsertion}State.countHistoryItems;
final revised = history.reviseSetItem(item);
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(revised);
''',
    );
  }



  
}
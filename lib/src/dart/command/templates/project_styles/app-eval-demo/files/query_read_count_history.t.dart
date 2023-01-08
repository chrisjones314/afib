

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_example_start_here.t.dart';

class QueryReadCountHistoryT extends QueryExampleStartHereT {
  QueryReadCountHistoryT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_read_count_history",
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: AFSourceTemplate.empty,
  );

  factory QueryReadCountHistoryT.example() {
    return QueryReadCountHistoryT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/count_history_items_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/count_history_item.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''',
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();
final uid = int.tryParse(userId);
final dbResults = db.select("SELECT * from \${CountHistoryItem.tableName} where \${CountHistoryItem.colUserId} = ?", [uid]);
final result = CountHistoryItemsRoot.fromDB(dbResults);
context.onSuccess(result);
''',
      insertFinishImpl: '''
final count = context.r;

// just save the count to our global state.
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(count);
''',
    );
  }



  
}
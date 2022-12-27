

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_example_start_here.t.dart';

class QueryWriteCountHistoryEntryT extends QueryExampleStartHereT {
  QueryWriteCountHistoryEntryT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_write_count_history_entry",
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: AFSourceTemplate.empty,
  );

  factory QueryWriteCountHistoryEntryT.example() {
    return QueryWriteCountHistoryEntryT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
''',
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();
final uid = int.tryParse(entry.userId);
db.select("INSERT INTO \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableCountHistory} (\${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colUserId}, \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colCount}) VALUES (?, ?)", [uid, entry.count]);
final revised = entry.reviseId(db.lastInsertRowId.toString());
context.onSuccess(revised);
''',
      insertFinishImpl: '''
final entry = context.r;
final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
final history = ${AFSourceTemplate.insertAppNamespaceInsertion}State.countHistory;
final revised = history.reviseAddEntry(entry);
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(revised);
''',
    );
  }



  
}
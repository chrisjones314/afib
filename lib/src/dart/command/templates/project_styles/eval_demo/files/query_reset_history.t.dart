

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_example_start_here.t.dart';

class QueryResetHistoryT extends QueryExampleStartHereT {
  QueryResetHistoryT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_reset_history",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryResetHistoryT.example() {
    return QueryResetHistoryT(
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/db/${AFSourceTemplate.insertAppNamespaceInsertion}_sqlite_db.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/count_history_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
''',
      insertMemberVariables: "final String userId;",
      insertConstructorParams: "required this.userId,",
      insertStartImpl: '''
final db = await ${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.accessDB();

final uid = int.tryParse(userId);
db.execute("delete from \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.tableCountHistory} where \${${AFSourceTemplate.insertAppNamespaceInsertion.upper}SqliteDB.colUserId} = ?", [uid]);
context.onSuccess(CountHistoryRoot.initialState());
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
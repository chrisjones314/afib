

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/start_here/files/query_example_start_here.t.dart';

class QueryReadCountInStateT extends QueryExampleStartHereT {
  QueryReadCountInStateT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
  }): super(
    templateFileId: "query_read_count_in_state",
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
  );

  factory QueryReadCountInStateT.example() {
    return QueryReadCountInStateT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/count_history_root.dart';
''',
      insertMemberVariables: 'final String userId;',
      insertConstructorParams: 'required this.userId,',
      insertStartImpl: '''
// See StartupQuery for an explanation of why you would never hard-code a test result
// in a real app.  This is an ideosyncracy of this example app.
Timer(const Duration(milliseconds: 250), () {
  context.onSuccess(CountHistoryRoot.initialState());
});
''',
      insertFinishImpl: '''
final count = context.r;

// just save the count to our global state.
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(count);
''',
    );
  }



  
}
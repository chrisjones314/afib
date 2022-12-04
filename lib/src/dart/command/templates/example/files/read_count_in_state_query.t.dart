

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/queries_t.dart';


class ReadCountInStateQueryFinishT extends AFSourceTemplate {

  const ReadCountInStateQueryFinishT();

  String get template => '''
final count = context.r;

// just save the count to our global state.
context.updateComponentRootStateOne<${insertAppNamespace.upper}State>(count);
''';

}

class ReadCountInStateQueryStartT extends AFSourceTemplate {

  const ReadCountInStateQueryStartT();

  String get template => '''
// See StartupQuery for an explanation of why you would never hard-code a test result
// in a real app.  This is an ideosyncracy of this example app.
Timer(const Duration(milliseconds: 250), () {
  context.onSuccess(CountHistoryRoot.initialState());
});
''';

}

class ReadCountInStateQueryMemberVariablesT extends AFSourceTemplate {

  const ReadCountInStateQueryMemberVariablesT();

  String get template => 'final String userId;';

}

class ReadCountInStateQueryConstructorParamsT extends AFSourceTemplate {
  const ReadCountInStateQueryConstructorParamsT();
  String get template => 'required this.userId,';
}

class ReadCountInStateQueryExtraImportsT extends AFSourceTemplate {

  const ReadCountInStateQueryExtraImportsT();

  String get template => '''
import 'package:$insertPackagePath/state/root/count_history_root.dart';
''';
}


class ReadCountInStateQuery extends SimpleQueryT {
  ReadCountInStateQuery({
    required AFSourceTemplate insertExtraImports,
    required AFSourceTemplate insertMemberVariables,
    required AFSourceTemplate insertStartImpl,
    required AFSourceTemplate insertConstructorParams,
    required AFSourceTemplate insertFinishImpl,
  }): super(
    templatePath: const [AFProjectPaths.folderExample, AFProjectPaths.folderCount, "query_read_count_in_state"],
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
  );

  factory ReadCountInStateQuery.example() {
    return ReadCountInStateQuery(
      insertExtraImports: const ReadCountInStateQueryExtraImportsT(),
      insertMemberVariables: const ReadCountInStateQueryMemberVariablesT(),
      insertConstructorParams: const ReadCountInStateQueryConstructorParamsT(),
      insertStartImpl: const ReadCountInStateQueryStartT(),
      insertFinishImpl: const ReadCountInStateQueryFinishT(),
    );
  }



  
}


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryStartupStarterMinimalT extends SimpleQueryT {
  QueryStartupStarterMinimalT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_startup",
    templateFolder: AFProjectPaths.pathGenerateStarterMinimalFiles,
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryStartupStarterMinimalT.example() {
    return QueryStartupStarterMinimalT(
      insertExtraImports: '''
''',
      insertMemberVariables: '''
''',
      insertConstructorParams: '''
''',
      insertStartImpl: '''
context.onSuccess(AFUnused.unused);
''',
      insertFinishImpl: '''
// TODO: The most likely thing you would do here is issue more queries, perhaps a CheckSigninQuery to see 
// if the user is already signed in.
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
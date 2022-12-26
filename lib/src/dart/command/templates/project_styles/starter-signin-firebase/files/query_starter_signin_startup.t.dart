

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryStarterSigninStartupFirebaseT extends SimpleQueryT {
  QueryStarterSigninStartupFirebaseT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_startup",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryStarterSigninStartupFirebaseT.example() {
    return QueryStarterSigninStartupFirebaseT(
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/listener/check_signin_listener_query.dart';
''',
      insertStartImpl: '''
context.onSuccess(AFUnused.unused);
''',
      insertFinishImpl: '''
context.executeQuery(CheckSigninListenerQuery());
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
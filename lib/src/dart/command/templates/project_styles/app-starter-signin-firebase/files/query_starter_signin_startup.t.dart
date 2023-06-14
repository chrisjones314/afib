

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_starter_signin_startup.t.dart';

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
      insertStartImpl: QueryStarterSigninStartupT.insertStartImplStartup,
      insertFinishImpl: '''
context.executeStandardAFibStartup(
  updateFrequency: const Duration(seconds: 1),
  defaultUpdateSpecificity: AFTimeStateUpdateSpecificity.day,
);

context.executeQuery(CheckSigninListenerQuery());
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
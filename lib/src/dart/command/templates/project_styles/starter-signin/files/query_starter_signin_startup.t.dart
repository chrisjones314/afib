

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryStarterSigninStartupT extends SimpleQueryT {
  QueryStarterSigninStartupT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_startup",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryStarterSigninStartupT.example() {
    return QueryStarterSigninStartupT(
      insertExtraImports: '''
import 'dart:async';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/check_signin_query.dart';
''',
      insertMemberVariables: AFSourceTemplate.empty,
      insertConstructorParams: AFSourceTemplate.empty,
      insertStartImpl: '''
context.onSuccess(AFUnused.unused);
''',
      insertFinishImpl: '''
context.executeQuery(CheckSigninQuery());
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
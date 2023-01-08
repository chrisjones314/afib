

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryWriteUserSigninStarterFirebaseT extends SimpleQueryT {
  QueryWriteUserSigninStarterFirebaseT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_write_user",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryWriteUserSigninStarterFirebaseT.example() {
    return QueryWriteUserSigninStarterFirebaseT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_user_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
''',
      insertStartImpl: '''
// TODO: You would actually write the user to your API/store, then 
// revise it with the actual id, and call onSuccess.
context.onSuccess(user.copyWith());
''',
      insertFinishImpl: '''
ReadUserQuery.onUpdateUser(context);
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
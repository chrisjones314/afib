

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryChangePasswordT extends SimpleQueryT {
  QueryChangePasswordT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_change_password",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryChangePasswordT.example() {
    return QueryChangePasswordT(
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_one_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
''',
      insertStartImpl: '''
user.updatePassword(newPassword).then((value) {
  context.onSuccess(AFUnused.unused);
}, onError: (err) {
  context.onError(AFQueryError.createMessage(err.toString()));
});
''',
      insertFinishImpl: AFSourceTemplate.empty,
      insertAdditionalMethods: AFSourceTemplate.empty,
    );
  }



  
}
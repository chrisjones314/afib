

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryChangeEmailT extends SimpleQueryT {
  QueryChangeEmailT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_change_email",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryChangeEmailT.example() {
    return QueryChangeEmailT(
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_one_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
''',
      insertStartImpl: '''
user.updateEmail(newEmail).then((value) {
  context.onSuccess(AFUnused.unused);
}).onError((error, stackTrace) {
  context.onError(AFQueryError(message: error.toString()));
});
''',
      insertFinishImpl: '''
// we need to keep the user record in sync with the firebase record
final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
final users = ${AFSourceTemplate.insertAppNamespaceInsertion}State.users;
final activeUser = users.findById(${AFSourceTemplate.insertAppNamespaceInsertion}State.userCredential.userId);
assert(activeUser != null);
if(activeUser != null) {
  final revised = activeUser.reviseEmail(newEmail);
  context.executeQuery(WriteOneUserQuery(credential: ${AFSourceTemplate.insertAppNamespaceInsertion}State.userCredential, user: revised));
}
''',
      insertAdditionalMethods: AFSourceTemplate.empty,
    );
  }



  
}
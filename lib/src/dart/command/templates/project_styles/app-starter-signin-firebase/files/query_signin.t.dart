

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_signin.t.dart';

class QuerySigninSigninStarterFirebaseT extends SimpleQueryT {
  QuerySigninSigninStarterFirebaseT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_signin",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QuerySigninSigninStarterFirebaseT.example() {
    return QuerySigninSigninStarterFirebaseT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/listener/read_one_user_listener_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
''',
      insertStartImpl: '''
FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password)
.then((result) {
  final signinRoot = convertCredential(result.user);
  context.onSuccess(signinRoot);
}).catchError((err) {
  context.onError(AFQueryError.createMessage(err.message));
});
''',
      insertFinishImpl: '''
onSuccessfulSignin(context);
''',
      insertAdditionalMethods: '''
${QuerySigninSigninStarterT.insertSigninAdditionalMethods('ReadOneUserListenerQuery')}

static UserCredentialRoot convertCredential(User? user) {
  // The issue here is that you cannot construct a UserCredential easily, which makes it really
  // difficult to provide query results in testing if your only result is a user credential.   In testing,
  // The most common baseline value you need is the unique user id.  
  return UserCredentialRoot(
    userId: user?.uid ?? UserCredentialRoot.notSpecified,
    storedEmail: user?.email ?? UserCredentialRoot.notSpecified,
    token: UserCredentialRoot.notSpecified,
  );
}
'''
    );
  }



  
}
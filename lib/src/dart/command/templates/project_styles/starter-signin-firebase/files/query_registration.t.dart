

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryRegistrationSigninStarterFirebaseT extends SimpleQueryT {
  QueryRegistrationSigninStarterFirebaseT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_registration",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryRegistrationSigninStarterFirebaseT.example() {
    return QueryRegistrationSigninStarterFirebaseT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/referenced_user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
''',
      insertStartImpl: '''
FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password
).then((result) {
  final userState = SigninQuery.convertCredential(result.user);
  context.onSuccess(userState);
}).catchError((err) {
  context.onError(AFQueryError.createMessage(err.message));
});
''',
      insertFinishImpl: '''
final cred = context.r;
context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(cred);

final revisedUser = newUser.reviseId(cred.userId);

// we have our user credential, now write the user record,
// and tell it to redirect to the home screen when it completes.
context.executeQuery(WriteUserQuery(
  credential: cred,
  user: revisedUser,
  onSuccess: (successCtx) {
    successCtx.navigateReplaceAll(HomePageScreen.navigatePush().castToReplaceAll());
  }
));
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
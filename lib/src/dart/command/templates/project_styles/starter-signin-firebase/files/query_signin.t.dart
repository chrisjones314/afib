

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

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
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_user_query.dart';
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
static void onSuccessfulSignin(AFFinishQuerySuccessContext<UserCredentialRoot> context) {
  final cred = context.response;
  assert(cred.isSignedIn);

  // save the user credential to our state.
  context.updateComponentRootStateOne<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>(cred);

  // TODO: you can execute several queries here to load in app data based on the user credential.
  // As written, this will only navigate to the home page once all the queries in startup load complete.
  final startupLoad = AFCompositeQuery.createList();
  startupLoad.add(ReadUserQuery(credential: cred));

  context.executeQuery(AFCompositeQuery.createFrom(
    queries: startupLoad, onSuccess: (successCtx) {
      // Then, when you've loaded enough state, you can navigate to the home screen.
      context.navigateReplaceAll(HomePageScreen.navigatePush().castToReplaceAll());
  }));
}

@override
void finishAsyncWithError(AFFinishQueryErrorContext context) {    
  final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
  lpi.updateSigninScreenStatus(status: AFSISigninStatus.error, message: context.e.message);
}

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
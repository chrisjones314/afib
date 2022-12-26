

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryCheckSigninSigninFirebaseStarterT extends SimpleQueryT {
  QueryCheckSigninSigninFirebaseStarterT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
    required Object insertMemberVariables,
    required Object insertConstructorParams,
  }): super.withMemberVariables(
    templateFileId: "query_check_signin",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
    insertConstructorParams: insertConstructorParams,
    insertMemberVariables: insertMemberVariables,
  );

  factory QueryCheckSigninSigninFirebaseStarterT.example() {
    return QueryCheckSigninSigninFirebaseStarterT(
      insertExtraImports: '''
import 'dart:async';
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
''',
      insertStartImpl: '''
subscription = FirebaseAuth.instance.authStateChanges().listen((user) { 
  final result = SigninQuery.convertCredential(user);
  context.onSuccess(result);
});
''',
      insertMemberVariables: '''
StreamSubscription? subscription;
''',
      insertConstructorParams: '''
this.subscription,
''',
      insertFinishImpl: '''
final cred = context.r;

if(cred.isSignedIn) {
  SigninQuery.onSuccessfulSignin(context);
} else {
  // if they are not signed in, we tell AFSI to transition from the loading state to the ready state on the signin screen.
  final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
  lpi.updateSigninScreenStatus(status: AFSISigninStatus.ready, storedEmail: cred.validStoredEmailOrEmpty);
}
''',
      insertAdditionalMethods: '''
@override
void shutdown() {
  subscription?.cancel();
  subscription = null;
}
'''
    );
  }



  
}
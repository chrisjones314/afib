

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QuerySigninSignoutStarterT extends SimpleQueryT {
  QuerySigninSignoutStarterT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_signout",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QuerySigninSignoutStarterT.example() {
    return QuerySigninSignoutStarterT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:afib_signin/afsi_flutter.dart';
''',
      insertMemberVariables: '''
final String storedEmail;
''',
      insertConstructorParams: '''
required this.storedEmail,
''',
      insertStartImpl: '''
// TODO: You would delete whatever saved token you have that captures the user signin.
context.onSuccess(UserCredentialRoot.createNotSignedIn());  
''',
      insertFinishImpl: '''
// you have to be careful about wiping out your active user credential here, as the currently 
// displayed screen might depend on it when it renders as part of the navigation to the signin screen.
// better to reset the entire state below.

// this doens't matter yet, but it shuts down all listener queries.
context.executeShutdownAllActiveQueries();

// the process of getting back to the signin screen is a little subtle, so let AFSI take care of it.
final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
lpi.navigateToSigninScreen(initialEmail: storedEmail);

// you presumably want to wipe out any user-data, and get back to the initial state, but not before the 
// navigation that is showing some part of your UI (and depends on that data) completes.
context.executeDeferredCallback(STQueryID.deferredSignout, const Duration(milliseconds: 500), (ctx) {
  context.executeResetToInitialState();
});
''',
      insertAdditionalMethods: '''
'''
    );
  }



  
}
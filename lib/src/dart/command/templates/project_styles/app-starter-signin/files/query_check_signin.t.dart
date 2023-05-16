

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryCheckSigninSigninStarterT extends SimpleQueryT {
  static const insertFinishImplSignin = '''
final cred = context.r;

if(cred.isSignedIn) {
  SigninQuery.onSuccessfulSignin(context);
} else {
  // if they are not signed in, we tell AFSI to transition from the loading state to the ready state on the signin screen.
  final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
  lpi.updateSigninScreenStatus(status: AFSISigninStatus.ready, storedEmail: cred.validStoredEmailOrEmpty);
}
''';

  QueryCheckSigninSigninStarterT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_check_signin",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryCheckSigninSigninStarterT.example() {
    return QueryCheckSigninSigninStarterT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:afib_signin/afsi_flutter.dart';
''',
      insertStartImpl: '''
  // AFIB_TODO: You will implement this method, checking whether you have a stored auth-token, and whether it is valid.  Using it,
  // you will call context.onSuccess with a user credential which either is or is not signed in.
  final stubCred = UserCredentialRoot.createNotSignedIn();
  context.onSuccess(stubCred);

''',
      insertFinishImpl: insertFinishImplSignin,
      insertAdditionalMethods: '''
'''
    );
  }



  
}
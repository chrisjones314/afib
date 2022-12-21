

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QuerySigninSigninStarterT extends SimpleQueryT {
  QuerySigninSigninStarterT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_signin",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QuerySigninSigninStarterT.example() {
    return QuerySigninSigninStarterT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/read_user_query.dart';

import 'package:afib_signin/afsi_flutter.dart';
''',
      insertMemberVariables: '''
final String email;
final String password;
final bool rememberMe;
''',
      insertConstructorParams: '''
required this.email,
required this.password,
required this.rememberMe,
''',
      insertStartImpl: '''
  // TODO: You will implement this method, hitting your API with the username/password, and calling 
  // context.onSuccess with a signed in user credential if successful, or context.onError with an appropriate error message
  // if not (store the email for retrieval in the CheckSigninQuery if 'rememberMe' is true).
  final testEmail = "test@nowhere.com";
  if(email == testEmail && password.isNotEmpty) {
    final signedInCred = UserCredentialRoot(
      userId: '12345',
      storedEmail: email,
      token: 'save your token',
    );
    context.onSuccess(signedInCred);
  } else {
    context.onError(AFQueryError(message: "Please enter \$testEmail and a non-empty password."));
  }
''',
      insertFinishImpl: '''
onSuccessfulSignin(context);
''',
      insertAdditionalMethods: '''
static void onSuccessfulSignin(AFFinishQuerySuccessContext<UserCredentialRoot> context) {
  final cred = context.response;
  assert(cred.isSignedIn);

  // save the user credential to our state.
  context.updateComponentRootStateOne<STState>(cred);

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

'''
    );
  }



  
}
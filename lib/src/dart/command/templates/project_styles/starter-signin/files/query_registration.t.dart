

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryRegistrationSigninStarterT extends SimpleQueryT {
  QueryRegistrationSigninStarterT({
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_registration",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryRegistrationSigninStarterT.example() {
    return QueryRegistrationSigninStarterT(
      insertExtraImports: '''
import 'package:afib/afib_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/root/user_credential_root.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/write_user_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/referenced_user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/home_page_screen.dart';
import 'package:afib_signin/afsi_flutter.dart';
''',
      insertMemberVariables: '''
final String email;
final String password;
final ReferencedUser newUser;
''',
      insertConstructorParams: '''
required this.email,
required this.password,
required this.newUser,
''',
      insertStartImpl: '''
// TODO: You would actually register the user, and create a new user credential using
// the actual ID.   You would probably also save the token you get back in the same way
// that you do in your SigninQuery, so that the user will be signed in from here on out.
final cred = UserCredentialRoot(
  userId: AFDocumentIDGenerator.createTestIdIncreasing("stub_exmaple_cred"),
  token: "--",
  storedEmail: email,
);
context.onSuccess(cred);
''',
      insertFinishImpl: '''
final cred = context.r;
context.updateComponentRootStateOne<STState>(cred);

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
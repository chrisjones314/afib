

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';

class SigninStarterSigninActionsLPIT {

   static LPIT example() {
    return LPIT(
      templateFileId: "starter_signin_actions_lpi",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
      insertExtraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
''',
      insertAdditionalMethods: '''
@override
void onSignin(String email, String password, { required bool rememberMe }) {
  context.executeQuery(SigninQuery(
    email: email,
    password: password,
    rememberMe: rememberMe,
  ));
}
''',
    );
  }
 
}
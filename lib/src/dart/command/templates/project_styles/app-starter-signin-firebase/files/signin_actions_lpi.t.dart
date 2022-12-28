

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/signin_actions_lpi.t.dart';

class SigninStarterSigninFirebaseActionsLPIT {

   static LPIT example() {
    return SigninStarterSigninActionsLPIT.custom(
      templateFileId: "starter_signin_actions_lpi",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
      extraImports: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/reset_password_query.dart';
''',
      additionalMethods: '''
@override
void onResetPassword(String email) {
  context.executeQuery(ResetPasswordQuery(email: email, onSuccess: (successCtx) {
    successCtx.showDialogInfoText(
      themeOrId: STFBThemeID.defaultTheme, 
      title: "Sent Password Reset",
      body: "Please check your email for password reset instructions."
    );
  })); 
}
''',
   );
  }
 
}
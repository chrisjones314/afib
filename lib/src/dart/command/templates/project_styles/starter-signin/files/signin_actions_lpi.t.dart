

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';

class SigninStarterSigninActionsLPIT {

   static LPIT example() {
    return LPIT(
      templateFileId: "starter_signin_actions_lpi",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
      insertExtraImports: '''
import 'package:afib_signin/afsi_flutter.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/registration_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/query/simple/signin_query.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/st_id.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/referenced_user.dart';
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/widgets/registration_details_widget.dart';

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

@override
void onSignup(String email, String password) {
  // Note: if you wanted to implement your own registration workflow, you could have done so 
  // by overriding onPressedSigninRegister, and navigating to your own registration screen.

  // But, this is a good example of how we can use an afib child widget and a theme override to insert
  // custom UI into UI's created by third parties.   Here, we can access the route param for the child widget
  // we returned from our STSigninTheme.
  final extraDetails = context.accessRouteParam<RegistrationDetailsWidgetRouteParam>(AFRouteParamRef.forWidget(
    screenId: AFSIScreenID.signup, 
    wid: STWidgetID.widgetRegistrationDetails
  ));

  assert(extraDetails != null);
  if(extraDetails == null) {
    return;
  }

  final newUser = ReferencedUser(
    id: AFDocumentIDGenerator.createNewId("user"), 
    email: email,
    firstName: extraDetails.firstName, 
    lastName: extraDetails.lastName, 
    zipCode: extraDetails.zipCode
  );
  
  final register = RegistrationQuery(
    email: email,
    password: password,
    newUser: newUser
  );
  
  context.executeQuery(register);
}
''',
    );
  }
 
}
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninFirebaseIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninFirebaseIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninFirebaseIntegrate,
  );

  String get template => '''
import project_styles/app-starter-signin-shared-integrate
generate query CheckSigninListenerQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/app-starter-signin-firebase/files/query_check_signin"
generate query ValidateAccountQuery --result-type fba.User --member-variables "String email; String password;" --override-templates "core/files/query_simple=project_styles/app-starter-signin-firebase/files/query_validate_for_delete_account"
generate query DeleteAccountQuery --result-type AFUnused --member-variables "fba.User user" --override-templates "core/files/query_simple=project_styles/app-starter-signin-firebase/files/query_delete_account"
generate query ChangeEmailQuery --result-type AFUnused --member-variables "fba.User user; String newEmail;" --override-templates "core/files/query_simple=project_styles/app-starter-signin-firebase/files/query_change_email"
generate query ChangePasswordQuery --result-type AFUnused --member-variables "fba.User user; String newPassword;" --override-templates "core/files/query_simple=project_styles/app-starter-signin-firebase/files/query_change_password"
affs:generate query WriteOneUserQuery --result-type User --member-variables "User user" --override-templates "core/files/query_write_one=project_styles/app-starter-signin-firebase/files/query_write_one_user"
affs:generate query ReadOneUserListenerQuery --result-type User --member-variables "String credentialUserId;" --override-templates "core/files/query_listen_one=project_styles/app-starter-signin-firebase/files/query_listen_one_user"
generate query SigninQuery --result-type UserCredentialRoot --member-variables "String email; String password; bool rememberMe" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_signin"
generate query ResetPasswordQuery --result-type AFUnused --member-variables "String email" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_forgot_password"
''';

}

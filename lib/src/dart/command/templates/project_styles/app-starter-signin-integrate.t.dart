import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninIntegrate,
  );

  String get template => '''
import project_styles/app-starter-signin-shared-integrate
generate query CheckSigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/app-starter-signin/files/query_check_signin"
generate query WriteOneUserQuery --result-type User --member-variables "UserCredentialRoot credential; User user" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_write_user"
generate query ReadUserQuery --result-type User --member-variables "UserCredentialRoot credential" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_read_user"
generate query SigninQuery --result-type UserCredentialRoot --member-variables "String email; String password; bool rememberMe" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_signin"
''';

}








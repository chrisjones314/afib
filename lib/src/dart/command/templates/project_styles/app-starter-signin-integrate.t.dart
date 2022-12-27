import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninIntegrate,
  );

  String get template => '''
import project_styles/app-starter-signin-shared-integrate
generate query CheckSigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/app-starter-signin/files/query_check_signin"
generate query WriteOneUserQuery --result-type ReferencedUser --member-variables "UserCredentialRoot credential; ReferencedUser user" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_write_user"
generate test StartupStateTest --force-overwrite --override-templates +
  +core/files/state_test=project_styles/app-starter-signin/files/state_test
''';

}








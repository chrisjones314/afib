import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninFirebaseIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninFirebaseIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninFirebaseIntegrate,
  );

  String get template => '''
import project_styles/app-starter-signin-shared-integrate
generate query CheckSigninListenerQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/app-starter-signin-firebase/files/query_check_signin"
affs:generate query WriteOneUserQuery --result-type ReferencedUser --member-variables "UserCredentialRoot credential;ReferencedUser user" --override-templates "core/files/write_one=project_styles/app-starter-signin-firebase/files/write_one_user"
''';

}

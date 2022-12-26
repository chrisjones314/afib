import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninFirebaseIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninFirebaseIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninFirebaseIntegrate,
  );

  String get template => '''
import project_styles/starter-signin-shared-integrate
generate query CheckSigninListenerQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin-firebase/files/query_check_signin"
''';

}

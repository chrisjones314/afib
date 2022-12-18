import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninIntegrate,
  );

  String get template => '''
generate override ${insertAppNamespaceUpper}SigninTheme --parent-type AFSIDefaultTheme
generate override ${insertAppNamespaceUpper}SigninActionsLPI --parent-type AFSISigninActionsLPI --override-templates "core/files/lpi=project_styles/starter-signin/files/starter_signin_actions_lpi"
generate custom set-startup-screen --screen-id AFSIScreenID.signin --create-route-param "SigninScreenRouteParam.createSigninLoading()"
generate query StartupQuery --result-type AFUnused --force-overwrite --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_startup" 
generate query CheckSigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_check_signin"
generate query SigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_signin"
generate ui HomePageScreen
echo --success "Project setup completed successfully."
''';

}








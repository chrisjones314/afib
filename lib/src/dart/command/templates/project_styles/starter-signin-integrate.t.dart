import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninIntegrateT extends AFProjectStyleSourceTemplate {

  StarterSigninIntegrateT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninIntegrate,
  );

  String get template => '''
generate id ${insertAppNamespaceUpper}QueryID.deferredSignout
generate override ${insertAppNamespaceUpper}SigninTheme --parent-type AFSIDefaultTheme --override-templates "core/files/theme=project_styles/starter-signin/files/theme_signin"
generate override ${insertAppNamespaceUpper}SigninActionsLPI --parent-type AFSISigninActionsLPI --override-templates "core/files/lpi=project_styles/starter-signin/files/starter_signin_actions_lpi"
generate custom set-startup-screen --screen-id AFSIScreenID.signin --create-route-param "SigninScreenRouteParam.createSigninLoading()"
generate state ReferencedUser --override-templates "core/files/model=project_styles/starter-signin/files/model_referenced_user"
generate state ReferencedUsersRoot --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_referenced_users_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_referenced_users_root_test_data
generate query StartupQuery --result-type AFUnused --force-overwrite --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_startup" 
generate query CheckSigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_check_signin"
generate query SigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_signin"
generate query SignoutQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_signout"
generate query RegistrationQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_registration"
generate query ReadUserQuery --result-type ReferencedUser --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_read_user"
generate query WriteUserQuery --result-type ReferencedUser --override-templates "core/files/query_simple=project_styles/starter-signin/files/query_write_user"
generate ui HomePageScreen --override-templates +
  +core/snippets/extra_imports=project_styles/starter-signin/snippets/home_page_screen_extra_imports
  +core/snippets/declare_spi=project_styles/starter-signin/snippets/home_page_screen_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/starter-signin/snippets/home_page_screen_build_body
generate ui RegistrationDetailsWidget --override-templates +
  +core/snippets/extra_imports=project_styles/starter-signin/snippets/registration_details_widget_extra_imports
  +core/snippets/widget_route_param=project_styles/starter-signin/snippets/registration_details_widget_route_param
  +core/snippets/declare_spi=project_styles/starter-signin/snippets/registration_details_widget_spi
  +core/snippets/widget_build_body=project_styles/starter-signin/snippets/registration_details_widget_build_body
echo --success "Project setup completed successfully."
''';

}








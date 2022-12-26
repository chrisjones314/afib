import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StarterSigninIntegrateSharedT extends AFProjectStyleSourceTemplate {

  StarterSigninIntegrateSharedT(): super(
    templateFileId: AFCreateAppCommand.projectStyleSigninSharedIntegrate,
  );

  String get template => '''
generate id ${insertAppNamespaceUpper}QueryID.deferredSignout
generate id ${insertAppNamespaceUpper}StateTestID.alreadyLoggedInWestCoast
generate id ${insertAppNamespaceUpper}StateTestID.alreadyLoggedInEastCoast
generate id ${insertAppNamespaceUpper}StateTestID.readyForLoginWestCoast
generate id ${insertAppNamespaceUpper}StateTestID.manipulateAfterSigninWestCoast
generate id ${insertAppNamespaceUpper}StateTestID.performLoginWestCoast
generate id ${insertAppNamespaceUpper}StateTestID.readyToRegister
generate id ${insertAppNamespaceUpper}StateTestID.registerMidwest
generate override ${insertAppNamespaceUpper}SigninTheme --parent-type AFSIDefaultTheme --override-templates "core/files/theme=project_styles/starter-signin/files/theme_signin"
generate override ${insertAppNamespaceUpper}SigninActionsLPI --parent-type AFSISigninActionsLPI --override-templates "core/files/lpi=project_styles/starter-signin/files/starter_signin_actions_lpi"
generate custom set-startup-screen --screen-id AFSIScreenID.signin --create-route-param "SigninScreenRouteParam.createSigninLoading()"
generate query StartupQuery --result-type AFUnused --force-overwrite --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_startup" 
generate query SigninQuery --result-type UserCredentialRoot --member-variables "String email; String password; bool rememberMe" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_signin"
generate query SignoutQuery --result-type UserCredentialRoot --member-variables "String storedEmail" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_signout"
generate query RegistrationQuery --result-type UserCredentialRoot --member-variables "String email; String password; ReferencedUser newUser" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_registration"
generate query ReadUserQuery --result-type ReferencedUser --member-variables "UserCredentialRoot credential" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_read_user"
generate query WriteUserQuery --result-type ReferencedUser --member-variables "UserCredentialRoot credential; ReferencedUser user" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_write_user"
generate ui HomePageScreen --override-templates +
  +core/snippets/extra_imports=project_styles/starter-signin/snippets/home_page_screen_extra_imports
  +core/snippets/declare_spi=project_styles/starter-signin/snippets/home_page_screen_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/starter-signin/snippets/home_page_screen_build_body
generate ui RegistrationDetailsWidget --override-templates +
  +core/snippets/extra_imports=project_styles/starter-signin/snippets/registration_details_widget_extra_imports
  +core/snippets/widget_route_param=project_styles/starter-signin/snippets/registration_details_widget_route_param
  +core/snippets/declare_spi=project_styles/starter-signin/snippets/registration_details_widget_spi
  +core/snippets/widget_build_body=project_styles/starter-signin/snippets/registration_details_widget_build_body
  +core/snippets/screen_additional_methods=project_styles/starter-signin/snippets/registration_details_widget_additional_methods
''';

}











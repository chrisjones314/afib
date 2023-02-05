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
generate id ${insertAppNamespaceUpper}QueryID.deferredAccountDelete
generate id ${insertAppNamespaceUpper}WidgetID.buttonSaveUserDetails
generate override ${insertAppNamespaceUpper}SigninTheme --parent-type AFSIDefaultTheme --override-templates "core/files/theme=project_styles/app-starter-signin/files/theme_signin"
generate override ${insertAppNamespaceUpper}SigninActionsLPI --parent-type AFSISigninActionsLPI --override-templates "core/files/lpi=project_styles/$insertProjectStyle/files/starter_signin_actions_lpi"
generate custom set-startup-screen --screen-id AFSIScreenID.signin --create-route-param "SigninScreenRouteParam.createSigninLoading()"
generate query StartupQuery --result-type AFUnused --force-overwrite --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_startup" 
generate query SignoutQuery --result-type UserCredentialRoot --member-variables "String storedEmail" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_signout"
generate query RegistrationQuery --result-type UserCredentialRoot --member-variables "String email; String password; User newUser" --override-templates "core/files/query_simple=project_styles/$insertProjectStyle/files/query_registration"
generate ui HomePageScreen --no-back-button --override-templates +
  +core/snippets/extra_imports=project_styles/app-starter-signin/snippets/home_page_screen_extra_imports
  +core/snippets/declare_spi=project_styles/app-starter-signin/snippets/home_page_screen_spi
  +core/snippets/empty_screen_build_body_impl=project_styles/app-starter-signin/snippets/home_page_screen_build_body
  +core/snippets/screen_build_with_spi_impl_no_back=project_styles/app-starter-signin/snippets/screen_build_with_spi_impl
  +core/snippets/screen_additional_methods=project_styles/app-starter-signin/snippets/home_page_screen_additional_methods
generate ui SignedInMenuDrawer --override-templates +
  +core/snippets/extra_imports=project_styles/app-starter-signin/snippets/signed_in_menu_drawer_extra_imports
  +core/snippets/declare_spi=project_styles/app-starter-signin/snippets/signed_in_menu_drawer_spi
  +core/snippets/drawer_build_body=project_styles/app-starter-signin/snippets/signed_in_menu_drawer_build_body
generate ui SignedInBottomNavBarWidget --override-templates +
  +core/snippets/extra_imports=project_styles/app-starter-signin/snippets/signed_in_bottom_nav_bar_extra_imports
  +core/snippets/declare_spi=project_styles/app-starter-signin/snippets/signed_in_bottom_nav_bar_spi
  +core/snippets/widget_build_body=project_styles/app-starter-signin/snippets/signed_in_bottom_nav_bar_build_body
generate ui RegistrationDetailsWidget --override-templates +
  +core/snippets/extra_imports=project_styles/app-starter-signin/snippets/registration_details_widget_extra_imports
  +core/snippets/screen_member_variable_decls=project_styles/app-starter-signin/snippets/screen_member_variable_decls
  +core/snippets/widget_params_constructor=project_styles/app-starter-signin/snippets/widget_params_constructor
  +core/snippets/widget_route_param=project_styles/app-starter-signin/snippets/registration_details_widget_route_param
  +core/snippets/declare_spi=project_styles/app-starter-signin/snippets/registration_details_widget_spi
  +core/snippets/widget_build_body=project_styles/app-starter-signin/snippets/registration_details_widget_build_body
  +core/snippets/screen_additional_methods=project_styles/app-starter-signin/snippets/registration_details_widget_additional_methods
generate test StartupStateTest --force-overwrite --override-templates +
  +core/files/state_test=project_styles/$insertProjectStyle/files/state_test
''';

}











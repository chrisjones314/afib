import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StartHereT extends AFProjectStyleSourceTemplate {

  StartHereT(): super(
    templateFileId: AFCreateAppCommand.projectStyleEvalDemo,
  );

  String get template => '''
--override-templates +
  +core/snippets/state_test_impl=project_styles/app-eval-demo/snippets/startup_state_test
require "meta, sqlite3, path_provider"
generate id ${insertAppNamespaceUpper}TestDataID.userWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.usersWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userMidwest
generate id ${insertAppNamespaceUpper}WidgetID.buttonSaveTransientCount
generate id ${insertAppNamespaceUpper}WidgetID.buttonResetHistory
generate id ${insertAppNamespaceUpper}TestDataID.countHistoryWestCoast
generate id ${insertAppNamespaceUpper}WidgetID.buttonIHaveNoObjection
generate id ${insertAppNamespaceUpper}WidgetID.textCurrentStanza
generate id ${insertAppNamespaceUpper}WidgetID.buttonManageCount
generate ui ${insertAppNamespaceUpper}DefaultTheme --parent-theme AFFunctionalTheme --parent-theme-id ${insertAppNamespaceUpper}ThemeID.defaultTheme --override-templates "core/files/theme=project_styles/app-eval-demo/files/start_here_theme"
generate state User --add-standard-root --member-variables "int id; String firstName; String lastName;String email;String zipCode" --override-templates +
  +core/files/model=project_styles/app-eval-demo/files/model_user
  +core/files/model_root=project_styles/app-eval-demo/files/model_users_root
  +core/snippets/define_test_data=project_styles/app-eval-demo/snippets/define_referenced_users_root_test_data
generate state CountHistoryItem --add-standard-root --member-variables "int id; int count;" --resolve-variables "User user;" --override-templates +
  +core/files/model=project_styles/app-eval-demo/files/model_count_history_item
  +core/files/model_root=project_styles/app-eval-demo/files/model_count_history_items_root
  +core/snippets/define_test_data=project_styles/app-eval-demo/snippets/define_count_history_root_test_data
generate state UserCredentialRoot --member-variables "String storedEmail; String token" --resolve-variables "User user;" --override-templates +
  +core/files/model_root=project_styles/app-eval-demo/files/model_user_credential_root
  +core/snippets/define_test_data=project_styles/app-eval-demo/snippets/define_user_credential_root_test_data
generate query ReadCountHistoryQuery --result-type CountHistoryItemsRoot --member-variables "String userId" --override-templates "core/files/query_simple=project_styles/app-eval-demo/files/query_read_count_history"
generate query ReadUserQuery --result-type User --member-variables "String userId" --override-templates "core/files/query_simple=project_styles/app-eval-demo/files/query_read_user"
generate query WriteCountHistoryItemQuery --result-type CountHistoryItem --member-variables "CountHistoryItem item" --override-templates "core/files/query_simple=project_styles/app-eval-demo/files/query_write_count_history_item"
generate query StartupQuery --result-type AFUnused --override-templates "core/files/query_simple=project_styles/app-eval-demo/files/query_startup"
generate query ResetHistoryQuery --result-type CountHistoryItemsRoot --member-variables "String userId" --override-templates "core/files/query_simple=project_styles/app-eval-demo/files/query_reset_history"
generate query CheckSigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/app-eval-demo/files/query_check_signin"
generate ui StartupScreen --override-templates +
  +core/snippets/screen_build_with_spi_impl=project_styles/app-eval-demo/snippets/startup_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/app-eval-demo/snippets/startup_screen_build_body
generate ui HomePageScreen --member-variables "int lineNumber;" --override-templates +
  +core/snippets/extra_imports=project_styles/app-eval-demo/snippets/home_page_screen_extra_imports
  +core/snippets/standard_route_param=project_styles/app-eval-demo/snippets/home_page_screen_route_param
  +core/snippets/declare_spi=project_styles/app-eval-demo/snippets/home_page_screen_spi
  +core/snippets/navigate_push=project_styles/app-eval-demo/snippets/home_page_screen_navigate_push
  +core/snippets/screen_build_with_spi_impl=project_styles/app-eval-demo/snippets/home_page_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/app-eval-demo/snippets/home_page_screen_build_body
  +core/snippets/screen_additional_methods=project_styles/app-eval-demo/snippets/home_page_screen_additional_methods
  +core/snippets/smoke_test_impl=project_styles/app-eval-demo/snippets/home_screen_smoke_test
generate ui CounterManagementScreen --member-variables "int clickCount;" --override-templates +
  +core/snippets/extra_imports=project_styles/app-eval-demo/snippets/counter_management_screen_extra_imports
  +core/snippets/standard_route_param=project_styles/app-eval-demo/snippets/counter_management_screen_route_param
  +core/snippets/declare_spi=project_styles/app-eval-demo/snippets/counter_management_screen_spi
  +core/snippets/navigate_push=project_styles/app-eval-demo/snippets/counter_management_screen_navigate_push
  +core/snippets/screen_build_with_spi_impl=project_styles/app-eval-demo/snippets/counter_management_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/app-eval-demo/snippets/counter_management_screen_build_body
  +core/snippets/screen_additional_methods=project_styles/app-eval-demo/snippets/counter_management_screen_additional_methods
  +core/snippets/smoke_test_impl=project_styles/app-eval-demo/snippets/counter_management_smoke_test
generate ui SignedInDrawer --override-templates +
  +core/snippets/extra_imports=project_styles/app-eval-demo/snippets/signed_in_drawer_extra_imports
  +core/snippets/declare_spi=project_styles/app-eval-demo/snippets/signed_in_drawer_spi
  +core/snippets/screen_build_with_spi_impl=project_styles/app-eval-demo/snippets/signed_in_drawer_build_with_spi
  +core/snippets/drawer_build_body=project_styles/app-eval-demo/snippets/signed_in_drawer_build_body
generate test StartupUnitTest  
generate test InitialWireframe --initial-screen HomePageScreen --override-templates +
  +core/snippets/wireframe_impl=project_styles/app-eval-demo/snippets/wireframe_impl
  +core/snippets/wireframe_body=project_styles/app-eval-demo/snippets/initial_wireframe_body
generate custom file --main-type ${insertAppNamespaceUpper}SqliteDB --path lib/state/db --override-templates "core/files/custom=project_styles/app-eval-demo/files/sqlite_db"
''';

}








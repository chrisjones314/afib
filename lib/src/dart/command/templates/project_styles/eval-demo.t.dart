import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StartHereT extends AFProjectStyleSourceTemplate {

  StartHereT(): super(
    templateFileId: AFCreateAppCommand.projectStyleEvalDemo,
  );

  String get template => '''
--override-templates +
  +core/snippets/state_test_impl=project_styles/eval_demo/snippets/startup_state_test
require meta
require sqlite3
require path_provider
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUsersWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialWestCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.userCredentialEastCoast
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserMidwest
generate id ${insertAppNamespaceUpper}WidgetID.buttonSaveTransientCount
generate id ${insertAppNamespaceUpper}WidgetID.buttonResetHistory
generate id ${insertAppNamespaceUpper}TestDataID.countHistoryWestCoast
generate id ${insertAppNamespaceUpper}WidgetID.buttonIHaveNoObjection
generate id ${insertAppNamespaceUpper}WidgetID.textCurrentStanza
generate id ${insertAppNamespaceUpper}WidgetID.buttonManageCount
generate ui ${insertAppNamespaceUpper}DefaultTheme --parent-theme AFFunctionalTheme --parent-theme-id ${insertAppNamespaceUpper}ThemeID.defaultTheme --override-templates "core/files/theme=project_styles/eval_demo/files/start_here_theme"
generate state CountHistoryEntry --override-templates "core/files/model=project_styles/eval_demo/files/model_count_history_entry" 
generate state CountHistoryRoot --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_count_history_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_count_history_root_test_data
generate state UserCredentialRoot --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_user_credential_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_user_credential_root_test_data
generate state ReferencedUsersRoot --override-templates +
  +core/files/model=project_styles/eval_demo/files/model_referenced_users_root
  +core/snippets/define_test_data=project_styles/eval_demo/snippets/define_referenced_users_root_test_data
generate state ReferencedUser --override-templates "core/files/model=project_styles/eval_demo/files/model_referenced_user"
generate query ReadCountHistoryQuery --result-type CountHistoryRoot --override-templates "core/files/query_simple=project_styles/eval_demo/files/query_read_count_history"
generate query ReadReferencedUserQuery --result-type ReferencedUser --override-templates "core/files/query_simple=project_styles/eval_demo/files/query_read_referenced_user"
generate query WriteCountHistoryEntryQuery --result-type CountHistoryEntry --override-templates "core/files/query_simple=project_styles/eval_demo/files/query_write_count_history_entry"
generate query StartupQuery --result-type AFUnused --override-templates "core/files/query_simple=project_styles/eval_demo/files/query_startup"
generate query ResetHistoryQuery --result-type CountHistoryRoot --override-templates "core/files/query_simple=project_styles/eval_demo/files/query_reset_history"
generate query CheckSigninQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/eval_demo/files/query_check_signin"
generate ui StartupScreen --override-templates +
  +core/snippets/screen_build_with_spi_impl=project_styles/eval_demo/snippets/startup_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/eval_demo/snippets/startup_screen_build_body
generate ui HomePageScreen --override-templates +
  +core/snippets/extra_imports=project_styles/eval_demo/snippets/home_page_screen_extra_imports
  +core/snippets/standard_route_param=project_styles/eval_demo/snippets/home_page_screen_route_param
  +core/snippets/declare_spi=project_styles/eval_demo/snippets/home_page_screen_spi
  +core/snippets/navigate_push=project_styles/eval_demo/snippets/home_page_screen_navigate_push
  +core/snippets/screen_build_with_spi_impl=project_styles/eval_demo/snippets/home_page_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/eval_demo/snippets/home_page_screen_build_body
  +core/snippets/screen_additional_methods=project_styles/eval_demo/snippets/home_page_screen_additional_methods
  +core/snippets/smoke_test_impl=project_styles/eval_demo/snippets/home_screen_smoke_test
generate ui CounterManagementScreen --override-templates +
  +core/snippets/extra_imports=project_styles/eval_demo/snippets/counter_management_screen_extra_imports
  +core/snippets/standard_route_param=project_styles/eval_demo/snippets/counter_management_screen_route_param
  +core/snippets/declare_spi=project_styles/eval_demo/snippets/counter_management_screen_spi
  +core/snippets/navigate_push=project_styles/eval_demo/snippets/counter_management_screen_navigate_push
  +core/snippets/screen_build_with_spi_impl=project_styles/eval_demo/snippets/counter_management_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/eval_demo/snippets/counter_management_screen_build_body
  +core/snippets/screen_additional_methods=project_styles/eval_demo/snippets/counter_management_screen_additional_methods
  +core/snippets/smoke_test_impl=project_styles/eval_demo/snippets/counter_management_smoke_test
generate ui SignedInDrawer --override-templates +
  +core/snippets/extra_imports=project_styles/eval_demo/snippets/signed_in_drawer_extra_imports
  +core/snippets/declare_spi=project_styles/eval_demo/snippets/signed_in_drawer_spi
  +core/snippets/screen_build_with_spi_impl=project_styles/eval_demo/snippets/signed_in_drawer_build_with_spi
  +core/snippets/drawer_build_body=project_styles/eval_demo/snippets/signed_in_drawer_build_body
generate test StartupUnitTest  
generate test InitialWireframe --initial-screen HomePageScreen --override-templates +
  +core/snippets/wireframe_body=project_styles/eval_demo/snippets/initial_wireframe_body
generate custom file --main-type ${insertAppNamespaceUpper}SqliteDB --path lib/state/db --override-templates "core/files/custom=project_styles/eval_demo/files/sqlite_db"
''';

}








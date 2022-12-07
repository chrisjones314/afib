import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StartHereT extends AFProjectStyleSourceTemplate {

  StartHereT(): super(
    templateFileId: AFCreateAppCommand.projectStyleStartHere,
  );

  String get template => '''
generate id ${insertAppNamespaceUpper}TestDataID.referencedUserChris
generate ui ${insertAppNamespaceUpper}DefaultTheme --parent-theme AFFunctionalTheme --parent-theme-id ${insertAppNamespaceUpper}ThemeID.defaultTheme --override-templates "core/files/theme=project_styles/start_here/files/start_here_theme"
generate state CountHistoryEntry --override-templates "core/files/model=project_styles/start_here/files/model_count_history_entry" 
generate state CountHistoryRoot --override-templates "core/files/model=project_styles/start_here/files/model_count_history_root"
generate state ReferencedUsersRoot --override-templates "core/files/model=project_styles/start_here/files/model_referenced_users_root"
generate state UserCredentialRoot --override-templates "core/files/model=project_styles/start_here/files/model_user_credential_root,core/snippets/define_test_data=project_styles/start_here/snippets/define_user_credential_root_test_data"
generate state ReferencedUser --override-templates "core/files/model=project_styles/start_here/files/model_referenced_user"
generate query ReadCountInStateQuery --result-type CountHistoryRoot --override-templates "core/files/query_simple=project_styles/start_here/files/query_read_count_in_state"
generate query ReadReferencedUserQuery --result-type ReferencedUser --override-templates "core/files/query_simple=project_styles/start_here/files/query_read_referenced_user"
generate query WriteCountHistoryEntryQuery --result-type CountHistoryEntry --override-templates "core/files/query_simple=project_styles/start_here/files/query_write_count_history_entry"
generate query StartupQuery --result-type UserCredentialRoot --override-templates "core/files/query_simple=project_styles/start_here/files/query_startup"
generate ui StartupScreen --override-templates +
  +core/snippets/extra_imports=project_styles/start_here/snippets/startup_screen_extra_imports
  +core/snippets/standard_route_param=project_styles/start_here/snippets/startup_screen_route_param
  +core/snippets/declare_spi=project_styles/start_here/snippets/startup_screen_spi
  +core/snippets/navigate_push=project_styles/start_here/snippets/startup_screen_navigate_push
  +core/snippets/screen_build_with_spi_impl=project_styles/start_here/snippets/startup_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/start_here/snippets/startup_screen_build_body
  +core/snippets/screen_additional_methods=project_styles/start_here/snippets/startup_screen_additional_methods
generate ui CounterManagementScreen --override-templates +
  +core/snippets/extra_imports=project_styles/start_here/snippets/counter_management_screen_extra_imports
  +core/snippets/standard_route_param=project_styles/start_here/snippets/counter_management_screen_route_param
  +core/snippets/declare_spi=project_styles/start_here/snippets/counter_management_screen_spi
  +core/snippets/navigate_push=project_styles/start_here/snippets/counter_management_screen_navigate_push
  +core/snippets/screen_build_with_spi_impl=project_styles/start_here/snippets/counter_management_screen_build_with_spi
  +core/snippets/minimal_screen_build_body_impl=project_styles/start_here/snippets/counter_management_screen_build_body
  +core/snippets/screen_additional_methods=project_styles/start_here/snippets/counter_management_screen_additional_methods
  +core/snippets/smoke_test_impl=project_styles/start_here/snippets/counter_management_smoke_test
generate ui SignedInDrawer --override-templates +
  +core/snippets/extra_imports=project_styles/start_here/snippets/signed_in_drawer_extra_imports
  +core/snippets/declare_spi=project_styles/start_here/snippets/signed_in_drawer_spi
  +core/snippets/screen_build_with_spi_impl=project_styles/start_here/snippets/signed_in_drawer_build_with_spi
  +core/snippets/drawer_build_body=project_styles/start_here/snippets/signed_in_drawer_build_body
''';

}








import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/command.t.dart';
import 'package:afib/src/dart/command/templates/core/files/command_afib.t.dart';
import 'package:afib/src/dart/command/templates/core/files/custom.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_base.t.dart';
import 'package:afib/src/dart/command/templates/core/files/library_exports.t.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/core/files/state_test.t.dart';
import 'package:afib/src/dart/command/templates/core/files/theme.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_model_accessor.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_drawer_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_empty_screen_build_body_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_fundamental_theme_init_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_additional_methods.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_build_with_spi_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_member_variable_decls.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_params_constructor.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_smoke_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_startup_screen_complete_project_style.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_state_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_params_constructor.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_route_param.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_wireframe_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_wireframe_impl.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_count_history_item.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_count_history_root.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_user_credential_root.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_users_root.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_check_signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_read_count_history.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_read_referenced_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_reset_history.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_start_here_startup.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/query_write_count_history_entry.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/sqlite_db.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/start_here_theme.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_counter_management_smoke_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_define_count_history_root_test_data.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_define_referenced_users_root_test_data.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_define_user_credential_root_test_data.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_home_screen_smoke_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_initial_wireframe_body.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_startup_state_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippet_wireframe_impl.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippets_counter_management_screen.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippets_home_page_screen.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippets_signed_in_drawer.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/snippets/snippets_startup_screen.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-minimal.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-minimal/files/query_minimal_startup.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-minimal/snippets/snippet_minimal_startup_screen_build_body.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase-integrate.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_change_email.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_change_password.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_check_signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_delete_account.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_read_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_registration.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_reset_password.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_signout.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_starter_signin_startup.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_validate_account.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/query_write_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/signin_actions_lpi.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/starter_firebase_main.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-firebase/files/state_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-integrate-shared.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-integrate.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin-shared.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/define_core.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/model_referenced_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/model_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_check_signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_read_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_registration.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_signout.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_starter_signin_startup.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/query_write_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/signin_actions_lpi.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/state_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/files/theme_signin.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/snippets/snippet_declare_active_user_accessor.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/snippets/snippet_fundmental_theme_init.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/snippets/snippets_home_page_screen.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/snippets/snippets_registration_details_widget.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/snippets/snippets_signed_in_bottom_nav_bar_widget.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-starter-signin/snippets/snippets_signed_in_menu_drawer.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/statelib-starter-minimal.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/uilib-starter-minimal.t.dart';
import 'package:path/path.dart';


/// A registry of source code templates umodel in code generation.
/// 
/// The templates can be registered using string ids, or 
/// [AFSourceTemplateID], the latter should be used for 
/// source that might be reused or overridden by third parties.
class AFTemplateRegistry {
  final templates = <dynamic, AFSourceTemplate>{};
  final fileTemplates = <String, AFFileSourceTemplate>{};
  final snippetTemplates = <String, AFSnippetSourceTemplate>{};
  
  AFTemplateRegistry() {
    registerFile(StarterMinimalT());
    registerFile(StartHereT());
    registerFile(StarterSigninT());
    registerFile(StarterSigninFirebaseT());
    registerFile(StarterSigninSharedT());
    registerFile(StarterSigninIntegrateSharedT());
    registerFile(StarterSigninFirebaseIntegrateT());
    registerFile(StateLibStarterMinimalT());
    registerFile(UILibStarterMinimalT());

    registerFile(SimpleQueryT.core());
    registerFile(SimpleQueryT.startupEmpty());
    registerFile(DeferredQueryT.core());
    registerFile(IsolateQueryT.core());
    registerFile(ModelT.core(isRoot: true));
    registerFile(ModelT.core(isRoot: false));
    registerFile(CommandAFibT());
    registerFile(LibraryExportsT());
    registerFile(InstallBaseT());
    registerFile(ThemeT.core());
    registerFile(CommandT());
    registerFile(CustomT.core());
    registerFile(StarterSigninIntegrateT());
    registerFile(LPIT.core());
    registerFile(StateTestT.core());

    registerSnippet(SnippetDefineTestDataT.core());
    registerSnippet(SnippetStandardRouteParamT.core());
    registerSnippet(SnippetScreenBuildWithSPIImplT.core());
    registerSnippet(SnippetEmptyScreenBuildBodyImplT());
    registerSnippet(SnippetDeclareSPIT.core());
    registerSnippet(SnippetScreenAdditionalMethodsT());
    registerSnippet(SnippetStandardRouteParamT.core());
    registerSnippet(SnippetNavigatePushT.core());
    registerSnippet(SnippetExtraImportsT.core());
    registerSnippet(SnippetDrawerBuildBodyT());
    registerSnippet(SnippetSmokeTestImplT());
    registerSnippet(SnippetStateTestImplT());
    registerSnippet(SnippetWireframeImplT.core());
    registerSnippet(SnippetWireframeBodyT());
    registerSnippet(SnippetStartupScreenCompleteProjectStyleT());
    registerSnippet(SnippetFundamentalThemeInitUILibraryT.core());
    registerSnippet(SnippetWidgetRouteParamT.core());
    registerSnippet(SnippetWidgetBuildBodyT.core());
    registerSnippet(SnippetStateTestImplMinimalT());
    registerSnippet(SnippetScreenParamsConstructorT.core());
    registerSnippet(SnippetWidgetParamsConstructorT.core());
    registerSnippet(SnippetScreenMemberVariableDeclsT.core());
    registerSnippet(SnippetDeclareModelAccessorT.core());
    registerSnippet(SnippetScreenBuildWithSPIImplT.coreNoBackButton());
    registerSnippet(SnippetEmptyScreenBuildBodyImplT());

    // starter-minimal example
    registerFile(QueryStartupStarterMinimalT.example());
    registerSnippet(SnippetMinimalScreenBuildBodyImplT());
    

    // start-here example
    registerFile(StartHereThemeT.example());
    registerFile(ModelCountHistoryRootT.example());
    registerFile(ModelCountHistoryItemT.example());
    registerFile(ModelUserT.example());
    registerFile(ModelUsersRootT.example());
    registerFile(ModelUserCredentialRootT.example());
    registerFile(QueryReadUserT.example());
    registerFile(QueryWriteCountHistoryItemT.example());
    registerFile(QueryReadCountHistoryT.example());
    registerFile(QueryStartHereStartupT.example());
    registerFile(StartHereThemeT.example());
    registerFile(SqliteDBT.example());
    registerFile(QueryResetHistoryT.example());
    registerFile(QueryCheckSigninT.example());

    registerSnippet(SnippetStartupScreenBuildWithSPIImplT());
    registerSnippet(SnippetStartupScreenBuildBodyT());

    registerSnippet(SnippetDefineUserCredentialRootTestDataT.example());
    registerSnippet(SnippetHomePageScreenExtraImports.example());
    registerSnippet(SnippetHomePageScreenSPIT.example());
    registerSnippet(SnippetHomePageScreenBuildWithSPIImplT());
    registerSnippet(SnippetHomePageScreenBuildBodyT());
    registerSnippet(SnippetHomePageScreenAdditionalMethodsT());
    registerSnippet(SnippetHomePageScreenRouteParamT.example());
    registerSnippet(SnippetHomePageScreenNavigatePushT.example());
    registerSnippet(SnippetHomeScreenSmokeTest());

    registerSnippet(SnippetCounterManagementScreenExtraImportsT.example());
    registerSnippet(SnippetCounterManagementScreenSPIT.example());
    registerSnippet(SnippetCounterManagementScreenBuildWithSPIImplT());
    registerSnippet(SnippetCounterManagementScreenBuildBodyT());
    registerSnippet(SnippetCounterManagementScreenAdditionalMethodsT());
    registerSnippet(SnippetCounterManagementScreenRouteParamT.example());
    registerSnippet(SnippetCounterManagementScreenNavigatePushT.example());
    registerSnippet(SnippetCounterManagementSmokeTest());

    registerSnippet(SnippetSignedInDrawerExtraImportsT.example());
    registerSnippet(SnippetSignedInDrawerSPIT.example());
    registerSnippet(SnippetSignedInDrawerBuildWithSPIImplT());
    registerSnippet(SnippetSignedInDrawerBuildBodyT());

    registerSnippet(SnippetStartupStateTestT());
    registerSnippet(SnippetDefineCountHistoryRootTestDataT.example());
    registerSnippet(SnippetDefineUsersRootTestDataT.example());
    
    registerSnippet(SnippetInitialWireframeBodyT());
    registerSnippet(SnippetEvalWireframeImplT.example());

    // starter-signin example
    registerFile(QueryStarterSigninStartupT.example());
    registerFile(QueryCheckSigninSigninStarterT.example());
    registerFile(SigninStarterSigninActionsLPIT.example());
    registerFile(QuerySigninSigninStarterT.example());
    registerFile(QuerySigninSignoutStarterT.example());
    registerFile(QueryRegistrationSigninStarterT.example());
    registerFile(StarterSigninModelUserT.example());
    registerFile(QueryReadUserSigninStarterT.example());
    registerFile(QueryWriteUserSigninStarterT.example());
    registerFile(StarterSigninThemeSigninT.example());
    registerFile(StarterSigninStateTestT.example());
    registerFile(SigninStarterDefineCoreT.example());
    registerFile(ModelSigninUserT.example());


    registerSnippet(SnippetSigninStarterHomePageScreenExtraImportsT.example());
    registerSnippet(SnippetSigninStarterHomePageScreenBuildBodyT());
    registerSnippet(SnippetSigninStarterHomePageScreenSPIT.example());
    registerSnippet(SnippetRegistrationDetailsWidgetExtraImportsT.example());
    registerSnippet(SnippetRegistrationDetailsWidgetRouteParamT());
    registerSnippet(SnippetRegistrationDetailsWidgetAdditionalMethodsT());
    registerSnippet(SnippetRegistrationDetailsWidgetBuildBodyT());
    registerSnippet(SnippetRegistrationDetailsWidgetSPIT.example());
    registerSnippet(SnippetSigninStarterFundamentalThemeInitT.example());
    registerSnippet(SnippetHomeScreenAdditionalMethodsT());
    registerSnippet(SnippetRegistrationDetailsWidgetParamsConstructorT.example());
    registerSnippet(SnippetRegistrationDetailsMemberVariablesDeclT.example());
    registerSnippet(SnippetHomeScreenBuildWithSPIImplT.example());
    registerSnippet(SnippetSigninStarterSignedInMenuDrawerExtraImportsT.example());
    registerSnippet(SnippetSigninStarterSignedInMenuDrawerBuildBodyT());
    registerSnippet(SnippetSigninStarterSignedInMenuDrawerSPIT.example());
    registerSnippet(SnippetSigninStarterSignedInBottomNavBarExtraImportsT.example());
    registerSnippet(SnippetSigninStarterSignedInBottomNavBarBuildBodyT());
    registerSnippet(SnippetSigninStarterSignedInBottomNavBarSPIT.example());
    registerSnippet(SnippetDeclareActiveUserAccessorT());
    registerSnippet(SnippetHomePageScreenSmokeTest());

    // starter-signin-firebase
    registerFile(StarterSigninFirebaseMainT.example());
    registerFile(QueryCheckSigninSigninFirebaseStarterT.example());
    registerFile(QuerySigninSigninStarterFirebaseT.example());
    registerFile(QuerySigninSignoutStarterFirebaseT.example());
    registerFile(QueryStarterSigninStartupFirebaseT.example());
    registerFile(QueryRegistrationSigninStarterFirebaseT.example());
    registerFile(QueryReadUserSigninStarterFirebaseT.example());
    registerFile(QueryWriteUserSigninStarterFirebaseT.example());
    registerFile(StarterSigninFirebaseStateTestT.example());
    registerFile(QueryForgotPasswordFirebaseStarterT.example());
    registerFile(SigninStarterSigninFirebaseActionsLPIT.example());
    registerFile(QueryValidateAccountT.example());
    registerFile(QueryDeleteAccountT.example());
    registerFile(QueryChangeEmailT.example());
    registerFile(QueryChangePasswordT.example());
  }  

  AFFileSourceTemplate? findEmbeddedTemplateFile(List<String> path) {
    final templateId = joinAll(path);
    return fileTemplates[templateId];
  }

  AFSnippetSourceTemplate? findEmbeddedTemplateSnippet(List<String> path) {
    final templateId = joinAll(path);
    return snippetTemplates[templateId];
  }

  Iterable<dynamic> get templateCodes {
    return templates.keys;
  }

  void registerFile(AFFileSourceTemplate source) {
    fileTemplates[source.templateId] = source;
  }

  void registerSnippet(AFSnippetSourceTemplate source) {
    snippetTemplates[source.templateId] = source;
  }

  void register(dynamic id, AFSourceTemplate source) {
    templates[id] = source;
  }

  AFSourceTemplate? find(dynamic id) {
    return templates[id];
  }
}
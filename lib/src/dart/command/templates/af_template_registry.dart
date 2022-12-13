import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/command.t.dart';
import 'package:afib/src/dart/command/templates/core/files/command_afib.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_base.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_library_base.t.dart';
import 'package:afib/src/dart/command/templates/core/files/library_exports.t.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';
import 'package:afib/src/dart/command/templates/core/files/theme.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_drawer_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_empty_screen_build_body_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_additional_methods.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_build_with_spi_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_smoke_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_state_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_wireframe_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_wireframe_impl.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/minimal.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval-demo.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_count_history_entry.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_count_history_root.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_referenced_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_referenced_users_root.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_user_credential_root.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_read_count_in_state.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_read_referenced_user.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_start_here_startup.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/query_write_count_history_entry.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/start_here_theme.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_counter_management_smoke_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_define_count_history_root_test_data.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_define_referenced_users_root_test_data.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_define_user_credential_root_test_data.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_home_screen_smoke_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_startup_state_test.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippet_initial_wireframe_body.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippets_counter_management_screen.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippets_home_page_screen.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippets_signed_in_drawer.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/snippets/snippets_startup_screen.t.dart';
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
    registerFile(MinimalT());
    registerFile(StartHereT());

    registerFile(SimpleQueryT.core());
    registerFile(DeferredQueryT.core());
    registerFile(IsolateQueryT.core());
    registerFile(ModelT.core());
    registerFile(CommandAFibT());
    registerFile(LibraryExportsT());
    registerFile(InstallBaseT());
    registerFile(ThemeT.core());
    registerFile(CommandT());

    registerSnippet(SnippetDefineTestDataT.core());
    registerSnippet(SnippetStandardRouteParamT.core());
    registerSnippet(SnippetScreenBuildWithSPIImplT());
    registerSnippet(SnippetMinimalScreenBuildBodyImplT());
    registerSnippet(SnippetDeclareSPIT.core());
    registerSnippet(SnippetMinimalScreenBuildBodyImplT());
    registerSnippet(SnippetScreenAdditionalMethodsT());
    registerSnippet(SnippetStandardRouteParamT.core());
    registerSnippet(SnippetNavigatePushT.core());
    registerSnippet(SnippetExtraImportsT.core());
    registerSnippet(SnippetDrawerBuildBodyT());
    registerSnippet(SnippetSmokeTestImplT());
    registerSnippet(SnippetStateTestImplT());
    registerSnippet(SnippetWireframeImplT());
    registerSnippet(SnippetWireframeBodyT());

    // start-here example
    registerFile(StartHereThemeT.example());
    registerFile(ModelCountHistoryRootT.example());
    registerFile(ModelCountHistoryEntryT.example());
    registerFile(ModelReferencedUserT.example());
    registerFile(ModelReferencedUsersRootT.example());
    registerFile(ModelUserCredentialRootT.example());
    registerFile(QueryReadReferencedUserT.example());
    registerFile(QueryWriteCountHistoryEntryT.example());
    registerFile(QueryReadCountInStateT.example());
    registerFile(QueryStartHereStartupT.example());
    registerFile(StartHereThemeT.example());

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
    registerSnippet(SnippetDefineReferencedUsersRootTestDataT.example());
    registerSnippet(SnippetInitialWireframeBodyT());
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
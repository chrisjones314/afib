import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/comments/build_body_intro.t.dart';
import 'package:afib/src/dart/command/templates/comments/build_with_spi.t.dart';
import 'package:afib/src/dart/command/templates/comments/config_decl_intro_comment.dart';
import 'package:afib/src/dart/command/templates/comments/navigate_push_intro.t.dart';
import 'package:afib/src/dart/command/templates/comments/route_param_intro.t.dart';
import 'package:afib/src/dart/command/templates/comments/spi_intro.t.dart';
import 'package:afib/src/dart/command/templates/files/afib.t.dart';
import 'package:afib/src/dart/command/templates/files/afib_test_config.t.dart';
import 'package:afib/src/dart/command/templates/files/app.t.dart';
import 'package:afib/src/dart/command/templates/files/app_state.t.dart';
import 'package:afib/src/dart/command/templates/files/appcode_afib.t.dart';
import 'package:afib/src/dart/command/templates/files/application.t.dart';
import 'package:afib/src/dart/command/templates/files/command.t.dart';
import 'package:afib/src/dart/command/templates/files/connected_base.t.dart';
import 'package:afib/src/dart/command/templates/files/create_dart_params.t.dart';
import 'package:afib/src/dart/command/templates/files/deferred_query.t.dart';
import 'package:afib/src/dart/command/templates/files/define_tests.t.dart';
import 'package:afib/src/dart/command/templates/files/define_ui.t.dart';
import 'package:afib/src/dart/command/templates/files/environment.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_app.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_app_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_base.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_command.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_test.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_library_base.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_library_command.t.dart';
import 'package:afib/src/dart/command/templates/files/extend_library_ui.t.dart';
import 'package:afib/src/dart/command/templates/files/id.t.dart';
import 'package:afib/src/dart/command/templates/files/install_command.t.dart';
import 'package:afib/src/dart/command/templates/files/install_ui.t.dart';
import 'package:afib/src/dart/command/templates/files/lib_exports.t.dart';
import 'package:afib/src/dart/command/templates/files/main.t.dart';
import 'package:afib/src/dart/command/templates/files/main_afib_test.t.dart';
import 'package:afib/src/dart/command/templates/files/main_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/files/model.t.dart';
import 'package:afib/src/dart/command/templates/files/screen.t.dart';
import 'package:afib/src/dart/command/templates/files/screen_test.t.dart';
import 'package:afib/src/dart/command/templates/files/simple_query.t.dart';
import 'package:afib/src/dart/command/templates/files/state_model_access.t.dart';
import 'package:afib/src/dart/command/templates/files/state_test_shortcuts.t.dart';
import 'package:afib/src/dart/command/templates/files/state_view.t.dart';
import 'package:afib/src/dart/command/templates/files/test_data.t.dart';
import 'package:afib/src/dart/command/templates/files/theme.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_route_param.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_view.t.dart';


/// A registry of source code templates umodel in code generation.
/// 
/// The templates can be registered using string ids, or 
/// [AFSourceTemplateID], the latter should be used for 
/// source that might be reused or overridden by third parties.
class AFTemplateRegistry {
  final templates = <dynamic, AFSourceTemplate>{};

  AFTemplateRegistry() {
    register(AFUISourceTemplateID.fileConfig, AFibT());
    register(AFUISourceTemplateID.fileScreen, AFScreenT());
    register(AFUISourceTemplateID.fileModel, AFModelT());
    register(AFUISourceTemplateID.fileTestConfig, AFTestConfigT());
    register(AFUISourceTemplateID.fileScreenTest, AFScreenTestT());
    register(AFUISourceTemplateID.fileAppcodeAFib, AFAppcodeAFibT());
    register(AFUISourceTemplateID.stmtDeclareID, DeclareIDStatementT());
    register(AFUISourceTemplateID.stmtDeclareRouteParam, DeclareRouteParamT());
    register(AFUISourceTemplateID.stmtDeclareStateView, DeclareStateViewT());
    register(AFUISourceTemplateID.fileSimpleQuery, SimpleQueryT());
    register(AFUISourceTemplateID.fileDeferredQuery, DeferredQueryT());
    register(AFUISourceTemplateID.stmtDeclareSPI, DeclareSPIT());
    register(AFUISourceTemplateID.fileExtendBase, AFExtendBaseT());
    register(AFUISourceTemplateID.fileExtendBaseLibrary, AFExtendLibraryBaseT());
    register(AFUISourceTemplateID.fileExtendCommand, AFExtendCommandT());
    register(AFUISourceTemplateID.fileExtendCommandLibrary, AFExtendLibraryCommandT());
    register(AFUISourceTemplateID.fileExtendLibrary, AFExtendLibraryUIT());
    register(AFUISourceTemplateID.fileExtendApplication, AFExtendApplicationT());
    register(AFUISourceTemplateID.fileMain, AFMainT());
    register(AFUISourceTemplateID.fileMainUILibrary, AFMainUILibraryT());
    register(AFUISourceTemplateID.fileApp, AFAppT());
    register(AFUISourceTemplateID.fileAppcodeID, AFAppcodeIDT());
    register(AFUISourceTemplateID.fileEnvironment, AFEnvironmentT());
    register(AFUISourceTemplateID.fileStateModelAccess, AFStateModelAccessT());
    register(AFUISourceTemplateID.fileState, AFAppStateT());
    register(AFUISourceTemplateID.fileStateView, AFStateViewT());
    register(AFUISourceTemplateID.fileMainAFibTest, AFMainAFibTestT());
    register(AFUISourceTemplateID.fileConnectedBase, AFConnectedBaseT());
    register(AFUISourceTemplateID.fileExtendApp, AFExtendAppT());
    register(AFUISourceTemplateID.fileExtendAppUILibrary, AFExtendAppUILibraryT());
    
    register(AFUISourceTemplateID.fileDefaultTheme, AFThemeT());
    register(AFUISourceTemplateID.fileExtendTest, AFExtendTestT());
    register(AFUISourceTemplateID.fileDefineTests, AFDefineTestsT());
    register(AFUISourceTemplateID.fileTestData, AFTestDataT());
    register(AFUISourceTemplateID.fileStateTestShortcuts, AFStateTestShortcutsT());
    register(AFUISourceTemplateID.fileDefineUI, AFDefineUIT());
    register(AFUISourceTemplateID.fileCommand, AFCommandT());
    register(AFUISourceTemplateID.fileLibExports, AFLibExportsT());
    register(AFUISourceTemplateID.fileInstallUI, AFInstallUIT());
    register(AFUISourceTemplateID.fileInstallCommand, AFInstallCommandT());
    
    
    register(AFUISourceTemplateID.fileCreateDartParams, AFCreateDartParamsT());
    register(AFUISourceTemplateID.commentSPIIntro, SPIIntroComment());
    register(AFUISourceTemplateID.commentRouteParamIntro, RouteParamIntroComment());
    register(AFUISourceTemplateID.commentConfigDecl, ConfigDeclIntroComment());
    register(AFUISourceTemplateID.commentNavigatePush, NavigatePushIntroComment());
    register(AFUISourceTemplateID.commentBuildWithSPI, BuildWithSPIComment());
    register(AFUISourceTemplateID.commentBuildBody, BuildBodyIntroComment());

  }  

  Iterable<dynamic> get templateCodes {
    return templates.keys;
  }

  void register(dynamic id, AFSourceTemplate source) {
    templates[id] = source;
  }

  AFSourceTemplate? find(dynamic id) {
    return templates[id];
  }
}
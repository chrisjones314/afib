import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/comments/build_body_intro.t.dart';
import 'package:afib/src/dart/command/templates/comments/build_with_spi.t.dart';
import 'package:afib/src/dart/command/templates/comments/config_decl_intro_comment.dart';
import 'package:afib/src/dart/command/templates/comments/route_param_intro.t.dart';
import 'package:afib/src/dart/command/templates/comments/spi_intro.t.dart';
import 'package:afib/src/dart/command/templates/core/command_afib.t.dart';
import 'package:afib/src/dart/command/templates/core/library_exports.t.dart';
import 'package:afib/src/dart/command/templates/core/queries_t.dart';
import 'package:afib/src/dart/command/templates/example/files/read_count_in_state_query.t.dart';
import 'package:afib/src/dart/command/templates/core/library_install_command.t.dart';
import 'package:afib/src/dart/command/templates/files/afib_test_config.t.dart';
import 'package:afib/src/dart/command/templates/core/app.t.dart';
import 'package:afib/src/dart/command/templates/files/command.t.dart';
import 'package:afib/src/dart/command/templates/core/connected_base.t.dart';
import 'package:afib/src/dart/command/templates/core/install_library_base.t.dart';
import 'package:afib/src/dart/command/templates/core/install_base.t.dart';
import 'package:afib/src/dart/command/templates/core/install_core.t.dart';
import 'package:afib/src/dart/command/templates/core/main.t.dart';
import 'package:afib/src/dart/command/templates/core/main_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/files/model_startup_example.t.dart';
import 'package:afib/src/dart/command/templates/core/screen.t.dart';
import 'package:afib/src/dart/command/templates/files/screen_test.t.dart';
import 'package:afib/src/dart/command/templates/core/theme.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/minimal.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/start-here.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_route_param.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_view.t.dart';
import 'package:path/path.dart';


/// A registry of source code templates umodel in code generation.
/// 
/// The templates can be registered using string ids, or 
/// [AFSourceTemplateID], the latter should be used for 
/// source that might be reused or overridden by third parties.
class AFTemplateRegistry {
  final templates = <dynamic, AFSourceTemplate>{};
  final fileTemplates = <String, AFFileSourceTemplate>{};
  
  AFTemplateRegistry() {
    registerFile(MinimalT());
    registerFile(StartHereT());

    registerFile(SimpleQueryT.base());
    registerFile(DeferredQueryT.base());
    registerFile(IsolateQueryT.base());
    registerFile(CommandAFibT());
    registerFile(LibraryExportsT());
    registerFile(InstallBaseT());

    // count example.
    registerFile(ReadCountInStateQuery.example());

    register(AFUISourceTemplateID.fileModelStartupExample, AFModelStartupExampleT());
    register(AFUISourceTemplateID.fileTestConfig, AFTestConfigT());
    register(AFUISourceTemplateID.fileScreenTest, AFScreenTestT());
    register(AFUISourceTemplateID.stmtDeclareID, DeclareIDStatementT());
    register(AFUISourceTemplateID.stmtDeclareRouteParam, DeclareRouteParamT());
    register(AFUISourceTemplateID.stmtDeclareStateView, DeclareStateViewT());
    register(AFUISourceTemplateID.fileExtendBaseLibrary, InstallLibraryBaseT());
    
    register(AFUISourceTemplateID.fileCommand, AFCommandT());
        
    register(AFUISourceTemplateID.commentSPIIntro, SPIIntroComment());
    register(AFUISourceTemplateID.commentRouteParamIntro, RouteParamIntroComment());
    register(AFUISourceTemplateID.commentConfigDecl, ConfigDeclIntroComment());
    register(AFUISourceTemplateID.commentBuildWithSPI, BuildWithSPIComment());
    register(AFUISourceTemplateID.commentBuildBody, BuildBodyIntroComment());

  }  

  AFFileSourceTemplate? findEmbeddedTemplate(List<String> path) {
    final templateId = joinAll(path);
    return fileTemplates[templateId];
  }

  Iterable<dynamic> get templateCodes {
    return templates.keys;
  }

  void registerFile(AFFileSourceTemplate source) {
    fileTemplates[source.templateId] = source;
  }

  void register(dynamic id, AFSourceTemplate source) {
    templates[id] = source;
  }

  AFSourceTemplate? find(dynamic id) {
    return templates[id];
  }
}
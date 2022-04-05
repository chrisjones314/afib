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
import 'package:afib/src/dart/command/templates/files/deferred_query.t.dart';
import 'package:afib/src/dart/command/templates/files/id.t.dart';
import 'package:afib/src/dart/command/templates/files/model.t.dart';
import 'package:afib/src/dart/command/templates/files/screen.t.dart';
import 'package:afib/src/dart/command/templates/files/screen_test.t.dart';
import 'package:afib/src/dart/command/templates/files/simple_query.t.dart';
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
    register(AFUISourceTemplateID.fileIds, IdentifierT());
    register(AFUISourceTemplateID.fileTestConfig, AFTestConfigT());
    register(AFUISourceTemplateID.fileScreenTest, AFScreenTestT());
    register(AFUISourceTemplateID.stmtDeclareID, DeclareIDStatementT());
    register(AFUISourceTemplateID.stmtDeclareRouteParam, DeclareRouteParamT());
    register(AFUISourceTemplateID.stmtDeclareStateView, DeclareStateViewT());
    register(AFUISourceTemplateID.fileSimpleQuery, SimpleQueryT());
    register(AFUISourceTemplateID.fileDeferredQuery, DeferredQueryT());
    register(AFUISourceTemplateID.stmtDeclareSPI, DeclareSPIT());
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
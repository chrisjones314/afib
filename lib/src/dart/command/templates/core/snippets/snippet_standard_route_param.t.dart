import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetStandardRouteParamT extends AFSnippetSourceTemplate {
  SnippetStandardRouteParamT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetStandardRouteParamT.core() {
    return SnippetStandardRouteParamT(
      templateFileId: "standard_route_param",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertConstructorParamsInsertion: AFSourceTemplate.empty, 
        AFSourceTemplate.insertMemberVariablesInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertCreateParamsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertCreateParamsCallInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertCopyWithParamsInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertCopyWithCallInsertion: AFSourceTemplate.empty,
        AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
      })
    );
  }
  
  String get template => '''
class ${insertMainType}RouteParam extends AF${ScreenT.insertControlTypeSuffix}RouteParam {
  $insertMemberVariables

  ${insertMainType}RouteParam($insertConstructorParams): super(screenId: ${ScreenT.insertScreenIDType}.${ScreenT.insertScreenID});

  factory ${insertMainType}RouteParam.create($insertCreateParams) {
    return ${insertMainType}RouteParam($insertCreateParamsCall);
  }

  ${ModelT.insertResolveMethods}
  ${ModelT.insertReviseMethods}

  ${insertMainType}RouteParam copyWith($insertCopyWithParams) {
    return ${insertMainType}RouteParam($insertCopyWithConstructorCall);
  }

  $insertAdditionalMethods
}
''';  
}

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetStandardRouteParamT extends AFSnippetSourceTemplate {
  static const insertWithFlutterStateSuffix = AFSourceTemplateInsertion("with_flutter_state_suffix");

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
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
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
  
  @override
  String get template => '''
class ${insertMainType}RouteParam extends AF${ScreenT.insertControlTypeSuffix}RouteParam$insertWithFlutterStateSuffix {
  $insertMemberVariables

  ${insertMainType}RouteParam($insertConstructorParams): super(
    screenId: ${ScreenT.insertScreenIDType}.${ScreenT.insertScreenID},
    ${AFSourceTemplate.insertSuperParamsInsertion}
  );

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

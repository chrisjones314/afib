import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetNavigatePushT extends AFSnippetSourceTemplate {
  static const insertNavigatePushParamDecl = AFSourceTemplateInsertion("navigate_push_param_decl");
  static const insertNavigatePushParamCall = AFSourceTemplateInsertion("navigate_push_param_call");

  SnippetNavigatePushT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });

  factory SnippetNavigatePushT.core() {
    return SnippetNavigatePushT(
      templateFileId: "navigate_push",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertNavigatePushParamDecl: AFSourceTemplate.empty,
        insertNavigatePushParamCall: AFSourceTemplate.empty,
      })
    );
  }

  @override
  String get template {
    return '''
static AFNavigatePushAction navigatePush($insertNavigatePushParamDecl) {
  return AFNavigatePushAction(
    launchParam: ${insertMainType}RouteParam.create($insertNavigatePushParamCall)
  );
}
  ''';
  }
}

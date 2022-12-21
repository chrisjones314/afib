import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetNavigatePushT extends AFSnippetSourceTemplate {
  static const insertParamDecl = AFSourceTemplateInsertion("param_decl");
  static const insertParamCall = AFSourceTemplateInsertion("param_call");

  SnippetNavigatePushT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

  factory SnippetNavigatePushT.core() {
    return SnippetNavigatePushT(
      templateFileId: "navigate_push",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertParamDecl: AFSourceTemplate.empty,
        insertParamCall: AFSourceTemplate.empty,
      })
    );
  }

  String get template {
    return '''
static AFNavigatePushAction navigatePush($insertParamDecl) {
  return AFNavigatePushAction(
    launchParam: ${insertMainType}RouteParam.create($insertParamCall)
  );
}
  ''';
  }
}

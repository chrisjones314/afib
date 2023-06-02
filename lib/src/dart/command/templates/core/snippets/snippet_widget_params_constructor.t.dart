
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetWidgetParamsConstructorT extends AFSnippetSourceTemplate {
  static const insertExtraConstructorParams = AFSourceTemplateInsertion("extra_constructor_params");
  
  SnippetWidgetParamsConstructorT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetWidgetParamsConstructorT.core() {
    return SnippetWidgetParamsConstructorT(
      templateFileId: "widget_params_constructor",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertExtraConstructorParams: AFSourceTemplate.empty,
      })
    );
  }

  @override
  String get template => '''{
    AFWidgetID? widOverride,
    required AFRouteParam launchParam,
    $insertExtraConstructorParams
}''';  
}

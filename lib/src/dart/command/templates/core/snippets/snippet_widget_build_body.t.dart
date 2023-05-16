
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetWidgetBuildBodyT extends AFSnippetSourceTemplate {

  SnippetWidgetBuildBodyT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetWidgetBuildBodyT.core() {
    return SnippetWidgetBuildBodyT(
      templateFileId: "widget_build_body",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {})
    );
  }

  String get template => '''
    final t = spi.t;
    return t.childText(text: "${insertMainType.spaces}");
''';
}

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetWidgetBuildBodyT extends AFSnippetSourceTemplate {

  SnippetWidgetBuildBodyT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });

  factory SnippetWidgetBuildBodyT.core() {
    return SnippetWidgetBuildBodyT(
      templateFileId: "widget_build_body",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {})
    );
  }

  @override
  String get template => '''
    final t = spi.t;
    return t.childText(text: "${insertMainType.spaces}");
''';
}
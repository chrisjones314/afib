import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetModelAdditionalMethodsT extends AFSnippetSourceTemplate {

  SnippetModelAdditionalMethodsT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });

  factory SnippetModelAdditionalMethodsT.core() {
    return SnippetModelAdditionalMethodsT(
      templateFileId: "model_additional_methods",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: null,
    );
  }

  @override
  String get template {
    return '''
  ''';
  }
}

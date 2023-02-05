import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetDeclareModelAccessorT extends AFSnippetSourceTemplate {

  SnippetDeclareModelAccessorT({
    String? templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId ?? "declare_root_accessor",
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

  factory SnippetDeclareModelAccessorT.core() {
    return SnippetDeclareModelAccessorT(
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets, 
      embeddedInsertions: null
    );
  }

  String get template => '''  $insertMainType get ${insertMainTypeNoRoot.camel} => findType<$insertMainType>();''';
}

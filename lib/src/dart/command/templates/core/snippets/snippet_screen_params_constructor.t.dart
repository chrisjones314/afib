
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenParamsConstructorT extends AFSnippetSourceTemplate {
  static const insertExtraConstructorParams = AFSourceTemplateInsertion("extra_constructor_params");
  
  SnippetScreenParamsConstructorT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetScreenParamsConstructorT.core() {
    return SnippetScreenParamsConstructorT(
      templateFileId: "screen_params_constructor",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        insertExtraConstructorParams: AFSourceTemplate.empty,
      })
    );
  }

  String get template => '$insertExtraConstructorParams';  
}


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenParamsConstructorT extends AFSnippetSourceTemplate {
  static const insertExtraConstructorParams = AFSourceTemplateInsertion("extra_constructor_params");
  
  SnippetScreenParamsConstructorT({
    required super.templateFileId,
    required super.templateFolder,
    required super.embeddedInsertions,
  });

  factory SnippetScreenParamsConstructorT.core() {
    return SnippetScreenParamsConstructorT(
      templateFileId: "screen_params_constructor",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertExtraConstructorParams: AFSourceTemplate.empty,
      })
    );
  }

  @override
  String get template => '$insertExtraConstructorParams';  
}

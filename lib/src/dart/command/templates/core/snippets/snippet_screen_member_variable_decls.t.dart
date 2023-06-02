
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetScreenMemberVariableDeclsT extends AFSnippetSourceTemplate {
  static const insertDecls = AFSourceTemplateInsertion("member_variable_decls");
  
  SnippetScreenMemberVariableDeclsT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetScreenMemberVariableDeclsT.core() {
    return SnippetScreenMemberVariableDeclsT(
      templateFileId: "screen_member_variable_decls",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        insertDecls: AFSourceTemplate.empty,
      })
    );
  }

  @override
  String get template => insertDecls.toString();
}

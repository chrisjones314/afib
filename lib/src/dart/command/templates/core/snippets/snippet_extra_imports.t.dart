

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetExtraImportsT extends AFSnippetSourceTemplate {

  SnippetExtraImportsT({
    required String templateFileId,
    required List<String> templateFolder,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

  factory SnippetExtraImportsT.core() {
    return SnippetExtraImportsT(
      templateFileId: "extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
      })
    );
  }

  String get template => '''
$insertExtraImports
''';
}
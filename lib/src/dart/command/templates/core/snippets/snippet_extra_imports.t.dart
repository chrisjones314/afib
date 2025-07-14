

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetExtraImportsT extends AFSnippetSourceTemplate {

  SnippetExtraImportsT({
    required super.templateFileId,
    required super.templateFolder,
    super.embeddedInsertions,
  });

  factory SnippetExtraImportsT.core() {
    return SnippetExtraImportsT(
      templateFileId: "extra_imports",    
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
      })
    );
  }

  @override
  String get template => '''
$insertExtraImports
''';
}
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetInitialState extends AFSourceTemplate {

  @override
  String get template => "$insertMainType.initialState()";

}

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDefineTestDataT extends AFSnippetSourceTemplate {
  static const insertModelDeclaration = AFSourceTemplateInsertion("model_declaration");
  static const insertModelCall = AFSourceTemplateInsertion("model_call");

  SnippetDefineTestDataT({
    required super.templateFileId,
    required super.templateFolder,
    super.embeddedInsertions,     
  });

  factory SnippetDefineTestDataT.core() {
    return SnippetDefineTestDataT(
      templateFileId: "define_test_data",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        SnippetDefineTestDataT.insertModelDeclaration: AFSourceTemplate.empty,
        SnippetDefineTestDataT.insertModelCall: SnippetInitialState(),
      })
    );
  }

  @override
  String get template => '''
void _define$insertMainType(AFDefineTestDataContext context) {
  $insertModelDeclaration

  context.define(${insertAppNamespaceUpper}TestDataID.stateFullLogin$insertMainType, $insertModelCall);
}

  ''';
}
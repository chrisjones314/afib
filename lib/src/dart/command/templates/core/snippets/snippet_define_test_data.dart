import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetInitialState extends AFSourceTemplate {

  String get template => "$insertMainType.initialState()";

}

class SnippetDefineTestDataT extends AFSnippetSourceTemplate {
  static const insertModelDeclaration = AFSourceTemplateInsertion("model_declaration");
  static const insertModelCall = AFSourceTemplateInsertion("model_call");

  SnippetDefineTestDataT({
    required String templateFileId,
    required List<String> templateFolder,
    AFSourceTemplateInsertions? embeddedInsertions,     
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

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

  String get template => '''
void _define$insertMainType(AFDefineTestDataContext context) {
  $insertModelDeclaration

  context.define(${insertAppNamespaceUpper}TestDataID.stateFullLogin$insertMainType, $insertModelCall);
}

  ''';
}
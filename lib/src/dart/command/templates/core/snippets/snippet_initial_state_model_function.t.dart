
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetInitialStateModelFunctionT extends AFSnippetSourceTemplate {
  static const insertInitialStateParams = AFSourceTemplateInsertion("initial_state_params");
  
  SnippetInitialStateModelFunctionT({
    required Object initialStateParams,

  }): super(
    templateFileId: "initial_state_params",
    templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
    embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      insertInitialStateParams: initialStateParams
    })
  );

  @override
  String get template => '''
static $insertMainType initialState() {
  return $insertMainType($insertInitialStateParams);
}
''';
}

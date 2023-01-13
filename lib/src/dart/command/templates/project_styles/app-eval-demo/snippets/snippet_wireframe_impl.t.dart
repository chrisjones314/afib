
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_wireframe_impl.t.dart';

class SnippetEvalWireframeImplT {
  static SnippetWireframeImplT example() {
    return SnippetWireframeImplT(
      templateFileId: "wireframe_impl",
      templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoSnippets,
      navPushParams: "lineNumber: 0",
    );
  }
}
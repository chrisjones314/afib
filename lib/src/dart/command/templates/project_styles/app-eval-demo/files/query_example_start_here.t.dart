
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryExampleStartHereT extends SimpleQueryT {
  QueryExampleStartHereT({
    required super.templateFileId,
    required Object super.insertExtraImports,
    required Object super.insertStartImpl,
    required Object super.insertFinishImpl,
    required Object super.insertAdditionalMethods,
  }): super(
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
  );

}
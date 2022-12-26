
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryExampleStartHereT extends SimpleQueryT {
  QueryExampleStartHereT({
    required String templateFileId,
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: templateFileId,
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
    insertExtraImports: insertExtraImports,
   insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

}
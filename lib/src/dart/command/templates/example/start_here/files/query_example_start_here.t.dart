
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryExampleStartHereT extends SimpleQueryT {
  QueryExampleStartHereT({
    required String templateFileId,
    required Object insertExtraImports,
    required Object insertMemberVariables,
    required Object insertStartImpl,
    required Object insertConstructorParams,
    required Object insertFinishImpl,
  }): super(
    templateFileId: templateFileId,
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereFiles,
    insertExtraImports: insertExtraImports,
    insertMemberVariables: insertMemberVariables,
    insertConstructorParams: insertConstructorParams,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
  );

}
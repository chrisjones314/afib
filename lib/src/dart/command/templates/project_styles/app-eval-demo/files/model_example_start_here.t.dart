import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';

class ModelExampleStartHereT extends ModelT {
  
  ModelExampleStartHereT({
    required super.templateFileId,
    super.embeddedInsertions,
  }): super(
    templateFolder: AFProjectPaths.pathGenerateExampleEvalDemoFiles,
  );  

}
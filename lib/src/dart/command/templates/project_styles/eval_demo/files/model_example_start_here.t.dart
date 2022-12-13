import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';

class ModelExampleStartHereT extends ModelT {
  
  ModelExampleStartHereT({
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: AFProjectPaths.pathGenerateExampleStartHereFiles,
    embeddedInsertions: embeddedInsertions,
  );  

}
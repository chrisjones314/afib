import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_example_start_here.t.dart';

class ModelUsersRootT extends ModelExampleStartHereT {
  
  ModelUsersRootT({
    List<String>? templatePath,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_users_root",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelUsersRootT.example() {
    return ModelUsersRootT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
''',
    }));
  }
}
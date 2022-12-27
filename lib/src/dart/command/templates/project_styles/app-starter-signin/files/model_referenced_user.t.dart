

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_referenced_user.t.dart';

class StarterSigninModelReferencedUserT {

  static ModelReferencedUserT example() {
    return ModelReferencedUserT.custom(
      templateFileId: "model_referenced_user", 
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles, 
      extraImports: AFSourceTemplate.empty, 
      additionalMethods: '''
ReferencedUser reviseId(String id) => copyWith(id: id);
''',
    );
  }
}
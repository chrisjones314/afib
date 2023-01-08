

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_user.t.dart';

class StarterSigninModelUserT {

  static ModelUserT example() {
    return ModelUserT.custom(
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles, 
      extraImports: AFSourceTemplate.empty, 
      additionalMethods: '''
''',
    );
  }
}




import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigureEnvironmentT extends AFFileSourceTemplate {
  static const insertEnvironmentName = AFSourceTemplateInsertion("environment_name");
  static const insertConfigureBody = AFSourceTemplateInsertion("configure_body");

  ConfigureEnvironmentT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "configure_environment"],
  );  

  String get template => '''
import 'package:afib/afib_command.dart';

void configure$insertEnvironmentName(AFConfig config) {   
   $insertConfigureBody
}
''';

}







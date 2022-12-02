



import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigureApplicationT extends AFFileSourceTemplate {

  ConfigureApplicationT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "configure_application"],
  );
  

  String get template => '''
import 'package:afib/afib_command.dart';

void configureApplication(AFConfig config) {
    
}
''';

}






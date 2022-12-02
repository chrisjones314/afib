



import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallCommandT extends AFFileSourceTemplate {

  InstallCommandT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "install_command"],
  );

  String get template => '''
import 'package:afib/afib_command.dart';

void installCommand(AFCommand${insertLibKind}ExtensionContext context) {
  // see 'afib generate command' for an easy way to create a new command-line command  
}
''';

}






import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallLibraryCommandT extends AFFileSourceTemplate {

  InstallLibraryCommandT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "install_library_command"],
  );  

  String get template => '''
import 'package:afib/afib_command.dart';

// You can use this function to add your own commands, or to
// import AFib-aware third party commands.
void installCommandLibrary(AFCommandLibraryExtensionContext context) {
}
''';

}

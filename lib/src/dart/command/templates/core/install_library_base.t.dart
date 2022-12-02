import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallLibraryBaseT extends AFFileSourceTemplate {

  InstallLibraryBaseT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "install_library_base"],
  );

  String get template => '''
import 'package:afib/afib_command.dart';

void installBaseLibrary(AFBaseExtensionContext context) {
  // the earliest/most basic hook for extending afib, both the command and the app
  // can be used to create custom configuration entries.
}
''';
}




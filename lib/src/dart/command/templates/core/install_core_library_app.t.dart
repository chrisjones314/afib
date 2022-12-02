

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallCoreLibraryAppT extends AFFileSourceTemplate {

  InstallCoreLibraryAppT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "install_core_library_app"],
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';

void installCoreLibrary(AFAppLibraryExtensionContext context) {
}
''';
}







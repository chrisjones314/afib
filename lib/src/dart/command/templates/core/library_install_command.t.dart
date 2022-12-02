


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class LibraryInstallCommandT extends AFFileSourceTemplate {

  LibraryInstallCommandT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "library_install_command"],
  );  

  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:$insertPackagePath/initialization/install/install_base.dart';
import 'package:$insertPackagePath/initialization/install/install_command.dart';

void ${insertAppNamespace}InstallCommand(AFCommandLibraryExtensionContext context) {
  installCommand(context);
}

void ${insertAppNamespace}InstallBase(AFBaseExtensionContext context) {
  context.registerLibrary(${insertAppNamespaceUpper}LibraryID.id);
  installBase(context);
}
''';
}

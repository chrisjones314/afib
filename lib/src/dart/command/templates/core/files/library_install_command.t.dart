import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class LibraryInstallCommandT extends AFCoreFileSourceTemplate {

  LibraryInstallCommandT(): super(
    templateFileId: "library_install_command",
  );  

  @override
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

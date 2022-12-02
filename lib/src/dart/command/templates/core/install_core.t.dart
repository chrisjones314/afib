
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class LibraryInstallCoreT extends AFFileSourceTemplate {
  static const insertIncludeInstallTests = AFSourceTemplateInsertion("include_install_tests");
  static const insertCallInstallTests = AFSourceTemplateInsertion("insert_install_tests");

  LibraryInstallCoreT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "library_install_core"],
  );  

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
$insertIncludeInstallTests

void ${insertAppNamespace}InstallCore(AFAppLibraryExtensionContext context) {
  final libContext = context.register(
    ${insertAppNamespaceUpper}LibraryID.id
  );
  if(libContext != null) {
    installCoreLibrary(libContext);
    $insertCallInstallTests
  }
}
''';
}

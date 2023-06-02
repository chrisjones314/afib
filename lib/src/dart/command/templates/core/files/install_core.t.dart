
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class LibraryInstallCoreT extends AFCoreFileSourceTemplate {
  static const insertIncludeInstallTests = AFSourceTemplateInsertion("include_install_tests");
  static const insertCallInstallTests = AFSourceTemplateInsertion("insert_install_tests");

  LibraryInstallCoreT(): super(
    templateFileId: "library_install_core",
  );  

  @override
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

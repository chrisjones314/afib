
import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class InstallCoreLibraryAppT extends AFCoreFileSourceTemplate {

  InstallCoreLibraryAppT(): super(
    templateFileId: "install_core_library_app",
  );

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';

void installCoreLibrary(AFAppLibraryExtensionContext context) {
}
''';
}







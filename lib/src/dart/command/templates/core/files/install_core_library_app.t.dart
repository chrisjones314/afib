
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallCoreLibraryAppT extends AFCoreFileSourceTemplate {

  InstallCoreLibraryAppT(): super(
    templateFileId: "install_core_library_app",
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';

void installCoreLibrary(AFAppLibraryExtensionContext context) {
}
''';
}







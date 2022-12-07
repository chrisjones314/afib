import 'package:afib/src/dart/command/af_source_template.dart';

class InstallLibraryBaseT extends AFCoreFileSourceTemplate {

  InstallLibraryBaseT(): super(
    templateFileId: "install_library_base",
  );

  String get template => '''
import 'package:afib/afib_command.dart';

void installBaseLibrary(AFBaseExtensionContext context) {
  // the earliest/most basic hook for extending afib, both the command and the app
  // can be used to create custom configuration entries.
}
''';
}




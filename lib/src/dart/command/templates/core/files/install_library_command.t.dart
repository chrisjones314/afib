import 'package:afib/src/dart/command/af_source_template.dart';

class InstallLibraryCommandT extends AFCoreFileSourceTemplate {

  InstallLibraryCommandT(): super(
    templateFileId: "install_library_command",
  );  

  String get template => '''
import 'package:afib/afib_command.dart';

// You can use this function to add your own commands, or to
// import AFib-aware third party commands.
void installCommandLibrary(AFCommandLibraryExtensionContext context) {
}
''';

}

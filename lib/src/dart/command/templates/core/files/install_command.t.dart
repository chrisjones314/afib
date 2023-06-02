import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class InstallCommandT extends AFCoreFileSourceTemplate {

  InstallCommandT(): super(
    templateFileId: "install_command",
  );

  @override
  String get template => '''
import 'package:afib/afib_command.dart';

void installCommand(AFCommand${insertLibKind}ExtensionContext context) {
  // see 'afib generate command' for an easy way to create a new command-line command  
}
''';

}






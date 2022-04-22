



import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendCommandT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';

void extendCommand(AFCommand[!af_lib_kind]ExtensionContext context) {

  // see 'afib generate command' for an easy way to create a new command-line command  
}
''';

}






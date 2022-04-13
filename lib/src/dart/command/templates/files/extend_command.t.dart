



import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendCommandT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';

// You can use this function to add your own commands, or to
// import AFib-aware third party commands.
void extendCommand(AFCommandExtensionContext definitions) {
  // see 'afib generate command' for an easy way to create a new command-line command  
}
''';

}






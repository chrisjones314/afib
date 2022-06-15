


import 'package:afib/src/dart/command/af_source_template.dart';

class AFCommandT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';

class [!af_command_name] extends AFCommand {

  @override
  final name = "[!af_app_namespace]:[!af_command_name_short(snake)]";

  @override
  final description = "TODO: describe your command";

  @override 
  String get usage {
    return \'\'\'
  \$nameOfExecutable generate command YourCommand
\$usageHeader

\$descriptionHeader
  \$description

\$optionsHeader
  None
\'\'\';
  }

  @override
  void execute(AFCommandContext context) {
    print("Executing \$name");

    final unnamed = context.unnamedArguments;
    if(unnamed == null || unnamed.isNotEmpty) {
      throwUsageError("Expected at least one arguments");
    }

    // see superclass verify... methods for useful verifications,
    // see throwUsageError for detected errors.

    // parse arguments with default values as follows
    final args = parseArguments(unnamed, defaults: {
        "your-arg": "yourdefaultvalue"
    });
  }
}
''';
  
}

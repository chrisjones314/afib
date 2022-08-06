


import 'package:afib/src/dart/command/af_source_template.dart';

class AFCommandT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';

class [!af_command_name] extends AFCommand {
  static const argExample = "example";

  @override
  final name = "[!af_app_namespace]:[!af_command_name_short(snake)]";

  @override
  final description = "TODO: describe your command";

  @override 
  String get usage {
    return \'\'\'
  \$nameOfExecutable \$name
\$usageHeader

\$descriptionHeader
  \$description

\$optionsHeader
  --\$argExample ExampleArgValue
\'\'\';
  }

  @override
  void execute(AFCommandContext context) {
    final rawArgs = context.rawArgs;

    // parse arguments with default values as follows
    final args = parseArguments(rawArgs, defaults: {
        argExample: "yourdefaultvalue"
    });

    // see superclass verify... methods for useful verifications,
    // see throwUsageError for reporting errors.

    final output = context.output;
    final unnamed = args.unnamed;
    final example = args.named[argExample];

    output.writeTwoColumns(
      col1: "named ",
      col2: unnamed.join(', ')
    );

    output.writeTwoColumns(
      col1: "unnamed ",
      col2: "\$argExample -> \$example"
    );
  }
}
''';
  
}

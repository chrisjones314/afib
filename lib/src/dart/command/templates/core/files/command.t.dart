


import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class CommandT extends AFCoreFileSourceTemplate {
  static const insertCommandName = AFSourceTemplateInsertion("command_name");
  static const insertCommandNameShort = AFSourceTemplateInsertion("command_name_short");

  CommandT(): super(templateFileId: "command");

  @override
  String get template => '''
import 'package:afib/afib_command.dart';

class $insertCommandName extends AFCommand {
  static const argExample = "example";

  @override
  final name = "$insertAppNamespace:${insertCommandNameShort.snake}";

  @override
  final description = "TODO: describe your command";

  @override 
  String get usage {
    return \'\'\'
  \$nameOfExecutable \$name YourValue [options]

\$usageHeader

\$descriptionHeader
  \$description

\$optionsHeader
  --\$argExample ExampleArgValue
\'\'\';
  }

  @override
  Future<void> execute(AFCommandContext context) async {

    // parse arguments with default values as follows
    final args = context.parseArguments(
      command: this,
      unnamedCount: 1,
      named: {
        argExample: "yourdefaultvalue"
      }
    );

    // see superclass verify... methods for useful verifications,
    // see throwUsageError for reporting errors.

    final output = context.output;
    final unnamed = args.accessUnnamedFirst;
    final example = args.accessNamed(argExample);

    output.writeTwoColumns(
      col1: "unnamed ",
      col2: unnamed,
    );

    output.writeTwoColumns(
      col1: "named ",
      col2: "\$argExample -> \$example"
    );
  }
}
''';
  
}

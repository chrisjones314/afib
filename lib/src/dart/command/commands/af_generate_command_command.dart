

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/command.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_define_command.t.dart';

/// Superclass for generation subcommands.
class AFGenerateCommandSubcommand extends AFGenerateSubcommand {
  AFGenerateCommandSubcommand();
  
  @override
  String get description => "Generate a custom command-line command, executed through $nameOfExecutable";

  @override
  String get name => "command";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate command YourCommand

$descriptionHeader
  $description

$optionsHeader
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final unnamed = context.rawArgs;
    if(unnamed.isEmpty) {
      throwUsageError("Expected one arguments");
    }

    final commandName = unnamed[0];
    verifyEndsWith(commandName, "Command");
    final generator = context.generator;

    final commandNameShort = generator.removeSuffix(commandName, "Command");

    // generate the command file itself.
    final fileCommand = context.createFile(generator.pathCommand(commandName), CommandT(), insertions: {
      CommandT.insertCommandName: commandName,
      CommandT.insertCommandNameShort: commandNameShort,
    });

    // register it 
    final fileExtend = generator.modifyFile(context, generator.pathExtendCommand);
    fileExtend.importFile(context, fileCommand);

    final declareDefine = context.createSnippet(SnippetCallDefineCommandT(), insertions: {
      CommandT.insertCommandName: commandName,
    });
    fileExtend.addLinesAfter(context, AFCodeRegExp.startExtendCommand, declareDefine.lines);
        
    // replace any default 
    generator.finalizeAndWriteFiles(context);
  }
}
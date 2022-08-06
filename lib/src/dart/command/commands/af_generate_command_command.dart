

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_command.t.dart';

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
  None
''';
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.rawArgs;
    if(unnamed.isEmpty) {
      throwUsageError("Expected one arguments");
    }

    final commandName = unnamed[0];
    verifyEndsWith(commandName, "Command");
    final generator = ctx.generator;

    final commandNameShort = generator.removeSuffix(commandName, "Command");

    // generate the command file itself.
    final fileCommand = createStandardFile(ctx, generator.pathCommand(commandName), AFUISourceTemplateID.fileCommand);
    fileCommand.replaceText(ctx, AFUISourceTemplateID.textCommandName, commandName);
    fileCommand.replaceText(ctx, AFUISourceTemplateID.textCommandNameShort, commandNameShort);

    // register it 
    final fileExtend = generator.modifyFile(ctx, generator.pathExtendCommand);
    generator.addImport(ctx, 
      importPath: fileCommand.importPathStatement, 
      to: fileExtend, 
      before: AFCodeRegExp.startExtendCommand);


    final declareDefine = DeclareDefineCommandT().toBuffer();
    declareDefine.replaceText(ctx, AFUISourceTemplateID.textCommandName, commandName);
    fileExtend.addLinesAfter(ctx, AFCodeRegExp.startExtendCommand, declareDefine.lines);
        
    // replace any default 
    generator.finalizeAndWriteFiles(ctx);
  }
}


import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/core/files/custom.t.dart';

class AFGenerateCustomSubcommand extends AFGenerateSubcommand {
  static const argPath = "path";
  AFGenerateCustomSubcommand();
  
  @override
  String get description => "Generate a custom file that isn't an afib concept, used in project-styles";

  @override
  String get name => "custom";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate $name YourMainType [any --options]

$descriptionHeader
  $description

$optionsHeader
  --$argPath - The relative path in the project (e.g. lib/state/db), it should include lib (if you want it), and should omit the filename, which is generated from YourMainType
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp

  ${AFCommand.argPrivateOptionHelp}

''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {

    final args = context.parseArguments(
      command: this,
      unnamedCount: 1,
      named: {
        argPath: "",
        argExportTemplates: "false",
        argOverrideTemplates: "",
      }
    );

    final mainType = args.accessUnnamedFirst;

    verifyMixedCase(mainType, "class name");

    final path = args.accessNamed(argPath);
    if(path.isEmpty) {
      throwUsageError("You must specify $argPath");
    }

    final projectPath = path.split("/");
    projectPath.add("${AFCodeGenerator.convertMixedToSnake(mainType)}.dart");

    // create the snippet, which is overriden.
    context.createFile(projectPath, CustomT.core(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: mainType
    });

      
    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }


}
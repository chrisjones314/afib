

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/custom.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_startup_screen.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFGenerateCustomSubcommand extends AFGenerateSubcommand {
  static const argPath = "path";
  static const argMainType = "main-type";
  static const argScreenId = "screen-id";
  static const argCreateRouteParam = "create-route-param";

  static const kindFile = "file";
  static const kindSetStartupScreen = "set-startup-screen";

  AFGenerateCustomSubcommand();
  
  @override
  String get description => "Various custom generation times, mostly used in project-styles";

  @override
  String get name => "custom";

  @override
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate $name [$kindFile|$kindSetStartupScreen] [any --options]

$descriptionHeader
  $description

$optionsHeader
  $kindFile - creates a custom file
    --$argMainType - The main type in the file, available via insertMainType in the template
    --$argPath - The relative path in the project (e.g. lib/state/db), it should include lib (if you want it), and should omit the filename, which is generated from the main type.
  
  $kindSetStartupScreen - changes the startup screen in the ${AFibD.config.appNamespace}_define_core.dart file
    --$argScreenId - the fully qualified screen id (e.g. AFSIScreenID.signin)
    --$argCreateRouteParam - the full syntax for creating the initial route parameter (e.g. SigninScreenRouteParam.createSigninLoading())
  
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp
  ${AFCommand.argPrivateOptionHelp}
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {

    final args = context.parseArguments(
      command: this,
      named: {
        argPath: "",
        argMainType: "",
        argScreenId: "",
        argCreateRouteParam: "",
        argExportTemplates: "false",
        argOverrideTemplates: "",
      }
    );

    final kind = args.accessUnnamedFirst;
    if(kind == kindFile) {
      await _createCustomFile(context, args);
    } else if(kind == kindSetStartupScreen) {
      await _setStartupScreen(context, args);
    } else {
      throwUsageError("Unknown custom kind $kind");
    }

    // replace any default 
    context.generator.finalizeAndWriteFiles(context);
  }

  Future<void> _createCustomFile(AFCommandContext context, AFCommandArgumentsParsed args) async {
    final mainType = args.accessNamed(argMainType);
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
  }

  Future<void> _setStartupScreen(AFCommandContext context, AFCommandArgumentsParsed args) async {
    final screenId = args.accessNamed(argScreenId);
    final createRouteParam = args.accessNamed(argCreateRouteParam);

    final defineLine = context.createSnippet(SnippetDefineStartupScreenT(), insertions: {
      SnippetDefineStartupScreenT.insertScreenId: screenId,
      SnippetDefineStartupScreenT.insertCreateRouteParam: createRouteParam,
    });

    final generator = context.generator;
    final fileDefineCore = generator.modifyFile(context, generator.pathDefineCore);
    
    final idx = fileDefineCore.findFirstLineContaining(context, AFCodeRegExp.defineStartupScreen);
    if(idx < 0) {
      throw AFCommandError(error: "Couldn't find ${AFCodeRegExp.defineStartupScreen} in ${generator.pathDefineCore}?");
    }

    // find the line containing the startup screen in the file.
    fileDefineCore.replaceLine(context, idx, defineLine.lines.first);
    context.output.writeTwoColumns(col1: "set-startup-screen", col2: "$screenId / $createRouteParam");
  }
}
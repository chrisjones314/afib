import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';

/// Parent for commands executed through the afib command line app.
class AFOverrideCommand extends AFCommand { 
  static const kindApp = "app";
  static const kindUILibrary = "ui_library";

  final String name = "override";
  final String description = "Override a theme from a 3rd party library";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable override [YourTheme] [--some required options, see below]

$descriptionHeader
  $description

$optionsHeader
  YourTheme - override a theme from a third party component, requires additional options:
    --${AFGenerateUISubcommand.argParentTheme} ParentTheme - the parent theme type from a third party
      component (e.g. AFSIDefaultTheme)
    --${AFGenerateUISubcommand.argParentThemeID} - the fully qualified name of the parent theme's id, 
      (e.g. 'AFSIThemeID.defaultTheme')

''';
  }


  AFOverrideCommand();

  void run(AFCommandContext ctx) {
    // override this to avoid 'error not in root of project'
    execute(ctx);
  }


  void execute(AFCommandContext ctx) {
    // first, determine the base path.
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.length < 3) {
      throwUsageError("Expected at least three arguments");
    }

    final uiName = unnamed[0];

    final generator = ctx.generator;
    if(uiName.endsWith("Theme")) {
      final args = parseArguments(unnamed, defaults: {
        AFGenerateUISubcommand.argParentTheme: generator.nameDefaultParentTheme,
        AFGenerateUISubcommand.argParentThemeID: generator.nameDefaultParentThemeID
      });

      AFGenerateUISubcommand.createTheme(ctx, uiName, args);
    } else if(uiName.endsWith("SPI")) {


    } else {
      throwUsageError("Expected $uiName to end with Theme or SPI");
    }

      generator.finalizeAndWriteFiles(ctx);
  }
}
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';

/// Parent for commands executed through the afib command line app.
class AFOverrideCommand extends AFCommand { 
  static const argParentType = "parent-type";
  static const themeSuffix = "Theme";
  static const spiSuffix = "SPI";
  static const lpiSuffix = "LPI";

  final String name = "override";
  final String description = "Override a theme or LPI from a 3rd party library";

  String get usage {
    return '''
$usageHeader
  $nameOfExecutable override [Your$themeSuffix|Your$lpiSuffix] [--some required options, see below]

$optionsHeader
  YourTheme - override a theme from a third party library, requires additional options:
    --$argParentType Parent$themeSuffix - the parent theme type from a third party
      component (e.g. AFSIDefaultTheme)

  YourLPI - override a Library Programming Interface from a third party library
    --$argParentType Parent$lpiSuffix - the parent LPI type from the third party library
      (e.g. AFSISigninActionsLPI)

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
    final args = parseArguments(unnamed, defaults: {
      argParentType: null,
    });

    final parentType = args[argParentType];
    if(parentType == null) {
      throwUsageError("You must specify --$argParentType");
    }

    final generator = ctx.generator;
    if(uiName.endsWith(themeSuffix)) {
      
      final fullId = generator.deriveFullLibraryIDFromType(parentType, themeSuffix);

      final args = parseArguments(unnamed, defaults: {
        AFGenerateUISubcommand.argParentTheme: parentType,
        AFGenerateUISubcommand.argParentThemeID: fullId
      });

      final fromLib = generator.findLibraryForTypeWithPrefix(parentType);
      AFGenerateUISubcommand.createTheme(ctx, uiName, args, 
        fullId: fullId,
        fromLib: fromLib,
      );
    } else if(uiName.endsWith(spiSuffix)) {


    } else if(uiName.endsWith(lpiSuffix)) {
      _generateLPIOverride(ctx, uiName, parentType);      
    } else {
      throwUsageError("Expected $uiName to end with Theme or SPI");
    }

      generator.finalizeAndWriteFiles(ctx);
  }

  void _generateLPIOverride(AFCommandContext ctx, String identifier, String parentType) {
    final generator = ctx.generator;

    // create the LPI file itself.
    final lpiPath = generator.pathLPI(identifier, isOverride: true);
    final lpiFile = generator.createFile(ctx, lpiPath, AFUISourceTemplateID.fileLPI);
    lpiFile.replaceText(ctx, AFUISourceTemplateID.textLPIType, identifier);

    final lib = generator.findLibraryForTypeWithPrefix(parentType);
    final fullId = generator.deriveFullLibraryIDFromType(parentType, lpiSuffix, typeKind: "LibraryProgrammingInterface");
    AFGenerateStateSubcommand.generateLPIStatic(ctx, identifier, <String, dynamic>{}, 
      fullId: fullId,
      fromLib: lib,
      parentType: parentType,
    );
  }

}
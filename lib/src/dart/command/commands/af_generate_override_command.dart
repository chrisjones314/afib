import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';

/// The command which handles 'generate override' 
class AFGenerateOverrideSubcommand extends AFCommand { 
  static const argParentType = "parent-type";
  static const themeSuffix = "Theme";
  static const spiSuffix = "SPI";
  static const lpiSuffix = "LPI";

  @override
  final String name = "override";
  @override
  final String description = "Override a theme or LPI from a 3rd party library";

  @override
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate override [Your$themeSuffix|Your$lpiSuffix] [--some required options, see below]

$optionsHeader
  YourTheme - override a theme from a third party library, requires additional options:
    --$argParentType Parent$themeSuffix - the parent theme type from a third party
      component (e.g. AFSIDefaultTheme)

  YourLPI - override a Library Programming Interface from a third party library
    --$argParentType Parent$lpiSuffix - the parent LPI type from the third party library
      (e.g. AFSISigninActionsLPI)

''';
  }


  AFGenerateOverrideSubcommand();

  @override
  Future<void> run(AFCommandContext ctx) async {
    // override this to avoid 'error not in root of project'
    await execute(ctx);
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    // first, determine the base path.
    final args = context.parseArguments(
      command: this, 
      unnamedCount: 1, 
      named: {
        argParentType: "",
        AFGenerateUISubcommand.argParentTheme: null,
        AFGenerateUISubcommand.argParentThemeID: null,
      }
    );

    final uiName = args.accessUnnamedFirst;
    final parentType = args.accessNamed(argParentType);
    if(parentType.isEmpty) {
      throwUsageError("You must specify --$argParentType");
    }

    final generator = context.generator;
    if(uiName.endsWith(themeSuffix)) {
      
      final fullId = generator.deriveFullLibraryIDFromType(parentType, themeSuffix);

      args.setIfNull(AFGenerateUISubcommand.argParentTheme, parentType);
      args.setIfNull(AFGenerateUISubcommand.argParentThemeID, fullId);
        
      final fromLib = generator.findLibraryForTypeWithPrefix(parentType);
      AFGenerateUISubcommand.createTheme(context, uiName, args, 
        fullId: fullId,
        fromLib: fromLib,
      );
    } else if(uiName.endsWith(spiSuffix)) {


    } else if(uiName.endsWith(lpiSuffix)) {
      _generateLPIOverride(context, uiName, parentType);      
    } else {
      throwUsageError("Expected $uiName to end with Theme or SPI");
    }

      generator.finalizeAndWriteFiles(context);
  }

  void _generateLPIOverride(AFCommandContext context, String identifier, String parentType) {
    final generator = context.generator;

    // create the LPI file itself.
    final lpiPath = generator.pathLPI(identifier, isOverride: true);
    context.createFile(lpiPath, LPIT.core(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: identifier,
    });

    final lib = generator.findLibraryForTypeWithPrefix(parentType);
    final fullId = generator.deriveFullLibraryIDFromType(parentType, lpiSuffix, typeKind: "LibraryProgrammingInterface");
    AFGenerateStateSubcommand.generateLPIStatic(context, identifier, AFCommandArgumentsParsed.empty(), 
      fullId: fullId,
      fromLib: lib,
      parentType: parentType,
    );
  }

}


import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;

class AFGenerateScreenSubcommand extends AFGenerateSubcommand {
  static const argRouteParam = "routeParam";
  static const argStateView = "stateView";
  static const argTheme = "theme";

  AFGenerateScreenSubcommand();
  
  @override
  String get description => "Generate a screen";

  @override
  String get name => "screen";


  String get usage {
    return '''
Usage
  afib.dart generate screen YourScreenName 

Description
  Create a new screen template under lib/ui/screens, adding an appropriate screen id and 
  test shortcut.

Options
  --$argStateView [YourStateView] - the state view to use, falls back to your default state view
  --$argTheme [YourTheme] - the theme to use, falls back to your default theme
  
''';
  }

  @override
  void registerArguments(args.ArgParser parser) {
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.isEmpty) {
      throwUsageError("You must specify at least the screen name.");
    }

    final expectedSuffix = "Screen";
    final screenName = verifyEndsWith(unnamed[0], expectedSuffix);
    verifyMixedCase(screenName, "screen name");
    verifyNotOption(screenName);
    final screenId = removeSuffixAndCamel(screenName, expectedSuffix);
    final ns = AFibD.config.appNamespace.toUpperCase();
    final defaultStateView = "${ns}DefaultStateView";
    final defaultTheme = "${ns}DefaultTheme";

    final args = parseArguments(unnamed, startWith: 1, defaults: {
      argStateView: defaultStateView,
      argTheme: defaultTheme,
    });

    final screenIdType = "${ns}ScreenID";
    final spiParentType = "${ns}ScreenSPI";

    // create a screen name
    final generator = ctx.generator;
    final projectPath = generator.pathScreen(screenName);
    final screenFile = generator.createFile(ctx, projectPath, AFUISourceTemplateID.fileScreen);

    final imports = <String>[];
    final stateView = args[argStateView];
    final theme = args[argTheme];
    final stateViewPrefix = generator.removeSuffix(stateView, "StateView");

    generator.addImportsForPath(ctx, generator.pathConnectedBaseFile, imports: imports);
    final pathStateView = generator.pathStateView(stateView);
    if(pathStateView != null) {
      generator.addImportsForPath(ctx, pathStateView, imports: imports);
    }
    final pathTheme = generator.pathTheme(theme);
    if(pathTheme != null) {
      generator.addImportsForPath(ctx, pathTheme, imports: imports);    
    }

    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenName, screenName);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textStateViewType, stateView);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenIDType, screenIdType);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textSPIParentType, spiParentType);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textThemeType, theme);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textStateViewPrefix, stateViewPrefix);
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textImportStatements, imports);

    /*
    TODO: enable this
    final idPath = generator.idFilePath;
    final idFile = generator.loadFile(ctx, idPath);
    final declareId = DeclareScreenIDStatementT().toBuffer();
    declareId.replaceText(ctx, AFUISourceTemplateID.textScreenName, screenName);
    declareId.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
    declareId.executeStandardReplacements(ctx);
    idFile.addLinesAfter(ctx, AFCodeRegExp.startScreenID, declareId.lines);
    */

    // TODO: add export in library, and do this for models and queries as well.

    // TODO: add test shortcut for screen

    // replace any default 
    generator.finalizeAndWriteFiles(ctx);
  }

}
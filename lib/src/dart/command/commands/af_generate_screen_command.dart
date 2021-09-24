

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.t.dart';
import 'package:args/args.dart' as args;

class AFGenerateScreenSubcommand extends AFGenerateSubcommand {
  static const argRouteParam = "route-param";

  AFGenerateScreenSubcommand();
  
  @override
  String get description => "Generate a screen";

  @override
  String get name => "screen";

  @override
  void registerArguments(args.ArgParser parser) {
  }

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.length != 1) {
      throw AFCommandError("Please specify the name of the screen to create in mixed case after other arguments");
    }

    final screenName = unnamed[0];

    if(screenName[0].toUpperCase() != screenName[0]) {
      throw AFCommandError("The screen name should be mixed case");
    }

    if(screenName.endsWith("Screen")) {
      throw AFCommandError("Please do not add 'Screen' to the screen name, AFib will add it for you");
    }

    // create a screen name
    final generator = ctx.generator;
    final projectPath = generator.pathScreen(screenName);
    final screenFile = generator.createFile(ctx, projectPath, AFUISourceTemplateID.fileScreen);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenName, screenName);

    final idPath = generator.idFilePath;
    final idFile = generator.loadFile(ctx, idPath);
    final declareId = DeclareIDStatementT().toBuffer();
    declareId.replaceText(ctx, AFUISourceTemplateID.textScreenName, screenName);
    declareId.executeStandardReplacements(ctx);
    idFile.addLinesAfter(ctx, RegExp("class\\s+.*ScreenID"), declareId.lines);

    // replace any default 
    generator.finalizeAndWriteFiles(ctx);
  }

}


import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/statements/declare_model_access_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;

class AFGenerateModelSubcommand extends AFGenerateSubcommand {
  static const kindRoot = "root";
  static const kindLeaf = "leaf";

  AFGenerateModelSubcommand();
  
  @override
  String get description => "Generate a model";

  @override
  String get name => "model";

  @override 
  String get usage {
    return '''
Usage 
  afib.dart generate model [$kindRoot|$kindLeaf] YourModelName

Description
  Creates a new model template in your state/models folder.  If you choose root, adds the model at the root
  of your state, and in your default state view.

Options
  $kindRoot: Use for a model that is referenced by the root of your state and by your default state view
  $kindLeaf: Use for a model that is not at the root of your state, and is referenced somewhere below your state
''';
  }

  @override
  void registerArguments(args.ArgParser parser) {
  }

  

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.length != 2) {
      throwUsageError("Expected two arguments");
    }

    final modelKind = unnamed[0];
    final modelName = unnamed[1];

    verifyMixedCase(modelName, "model name");
    verifyUsageOption(modelKind, [
      kindRoot,
      kindLeaf
    ]);

    // create a screen name
    final generator = ctx.generator;
    final modelPath = generator.pathModel(modelName);
    final modelFile = generator.createFile(ctx, modelPath, AFUISourceTemplateID.fileModel);

    modelFile.replaceText(ctx, AFUISourceTemplateID.textModelName, modelName);

    // if its a root model, we need to add it to the default state view access
    if(modelKind == kindRoot) {
      final pathStateViewAccess = generator.pathStateViewAccess();
      final accessFile = generator.modifyFile(ctx, pathStateViewAccess);
      final regexMixinStart = AFCodeRegExp.startMixinStateAccess;
      final declareAccess = DeclareModelAccessStatementT().toBuffer();
      declareAccess.replaceText(ctx, AFUISourceTemplateID.textModelName, modelName);
      accessFile.addLinesAfter(ctx, regexMixinStart, declareAccess.lines);

      final declareImport = ImportFromPackage().toBuffer();
      declareImport.replaceText(ctx, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
      declareImport.replaceText(ctx, AFUISourceTemplateID.textPackagePath, modelFile.importPathStatement);
      
      accessFile.addLinesBefore(ctx, regexMixinStart, declareImport.lines);
      /*
      final idPath = generator.idFilePath;
      final idFile = generator.loadFile(ctx, idPath);
      final declareId = DeclareIDStatementT().toBuffer();
      declareId.replaceText(ctx, AFUISourceTemplateID.textScreenName, screenName);
      declareId.executeStandardReplacements(ctx);
      idFile.addLinesAfter(ctx, RegExp("class\\s+.*ScreenID"), declareId.lines);
      */
      
    }


    // replace any default 
    generator.finalizeAndWriteFiles(ctx);

  }

}
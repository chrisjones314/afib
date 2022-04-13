

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_screen_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/statements/declare_initial_value.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_model_access_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFGenerateStateSubcommand extends AFGenerateSubcommand {
  static const modelSuffix = "Model";
  static const stateViewSuffix = "StateView";

  AFGenerateStateSubcommand();
  
  @override
  String get description => "Generate a state model or state view";

  @override
  String get name => "state";

  @override 
  String get usage {
    return '''
Usage 
  afib generate state [YourModel|YourStateView] [any --options]

Description
  If your identifier ends with Model, creates a new model linked to the root of your application state.
  If your identifier ends with StateView, creates a new state view and supporting classes for that state view

Options
  --${AFGenerateScreenSubcommand.argTheme} The type of the theme to use, defaults to your default theme
  ${AFCommand.argPrivateOptionHelp}

''';
  }

  

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.isEmpty) {
      throwUsageError("Expected at least one argument");
    }

    final modelName = unnamed[0];

    verifyMixedCase(modelName, "model name");
    verifyEndsWithOneOf(modelName, [modelSuffix, stateViewSuffix]);

    final args = parseArguments(unnamed, defaults: {
      AFGenerateScreenSubcommand.argTheme: ctx.generator.nameDefaultTheme
    });

    generateStateStatic(ctx, modelName, args);


    // replace any default 
    ctx.generator.finalizeAndWriteFiles(ctx);

  }

  static void generateStateStatic(AFCommandContext ctx, String identifier, Map<String, dynamic> args) {
    if(identifier.endsWith(modelSuffix)) {
      _generateModelStatic(ctx, identifier, args);
    } else {
      _generateStateViewStatic(ctx, identifier, args);
    }
  }
  
  
  static void _generateModelStatic(AFCommandContext ctx, String identifier, Map<String, dynamic> args) {
    
    // generate the model file itself.
    final generator = ctx.generator;
    final modelPath = generator.pathModel(identifier);
    final modelFile = generator.createFile(ctx, modelPath, AFUISourceTemplateID.fileModel);

    modelFile.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);

    // add it to the root application state
    final pathState = generator.pathAppState;
    final stateFile = generator.modifyFile(ctx, pathState);
    generator.addImport(ctx,
      importPath: modelFile.importPathStatement,
      to: stateFile,
      before: AFCodeRegExp.startDefineStateClass
    );

    // add its initial value to the state
    final declareInitialValue = DeclareInitialValueT().toBuffer();
    declareInitialValue.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);
    stateFile.addLinesAfter(ctx, AFCodeRegExp.startReturnInitialState, declareInitialValue.lines);

    // we need to add it to the default state view access
    final pathStateViewAccess = generator.pathStateViewAccess();
    final accessFile = generator.modifyFile(ctx, pathStateViewAccess);
    final regexMixinStart = AFCodeRegExp.startMixinStateAccess;
    final declareAccess = DeclareModelAccessStatementT().toBuffer();
    declareAccess.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);
    accessFile.addLinesAfter(ctx, regexMixinStart, declareAccess.lines);

    final declareImport = ImportFromPackage().toBuffer();
    declareImport.replaceText(ctx, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
    declareImport.replaceText(ctx, AFUISourceTemplateID.textPackagePath, modelFile.importPathStatement);
    
    accessFile.addLinesBefore(ctx, regexMixinStart, declareImport.lines);

    // export it
    generator.addExportsForFiles(ctx, args, [
      modelFile
    ]);

  }

  static void _generateStateViewStatic(AFCommandContext ctx, String identifier, Map<String, dynamic> args) {
    final generator = ctx.generator;
    if(!identifier.startsWith(generator.appNamespaceUpper)) {
      throw AFCommandError(error: "$identifier must begin with ${generator.appNamespaceUpper}");
    }

    final stateViewPath = generator.pathStateView(identifier);

    if(stateViewPath == null) {
      throw AFCommandError(error: "Invalid identifier $identifier");
    }
    final theme = args[AFGenerateScreenSubcommand.argTheme];
    final stateViewFile = generator.createFile(ctx, stateViewPath, AFUISourceTemplateID.fileStateView);
    stateViewFile.replaceText(ctx, AFUISourceTemplateID.textStateViewName, identifier);
    stateViewFile.replaceText(ctx, AFUISourceTemplateID.textThemeType, theme);
    stateViewFile.replaceText(ctx, AFUISourceTemplateID.textStateViewPrefix, generator.removeSuffix(identifier, stateViewSuffix));
    stateViewFile.executeStandardReplacements(ctx);

    final imports = <String>[];
    // if we can find the specified theme, then we need to import it.
    final pathTheme = generator.pathTheme(theme);
    if(pathTheme != null) {
      generator.addImportsForPath(ctx, pathTheme, imports: imports, requireExists: false);    
    }

    stateViewFile.replaceTextLines(ctx, AFUISourceTemplateID.textImportStatements, imports);

    generator.addExportsForFiles(ctx, args, [
      stateViewFile
    ]);

  }

}
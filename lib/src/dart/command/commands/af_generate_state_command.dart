

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_define_test_data.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_define_test_data.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_lpi.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_initial_value.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_lpi_id_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_model_access_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_reference_test_data.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_test_id.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFGenerateStateSubcommand extends AFGenerateSubcommand {

  AFGenerateStateSubcommand();
  
  @override
  String get description => "Generate a state model or state view";

  @override
  String get name => "state";

  @override 
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate state [Your${AFCodeGenerator.rootSuffix}|Your${AFCodeGenerator.stateViewSuffix}|Your${AFCodeGenerator.lpiSuffix}|YourModelWithNoSpecialSuffix] [any --options]

$descriptionHeader
  If your identifier ends with ${AFCodeGenerator.rootSuffix}, creates a new root model linked to the root of your component/application state.
  If your identifier ends with ${AFCodeGenerator.stateViewSuffix}, creates a new state view and supporting classes for that state view
  If your identifier ends with ${AFCodeGenerator.lpiSuffix}, creates a new LibraryProgrammingInterface (primarily used in libraries, app usually override existing LPIs)
  If your identifer does not end with any special suffix, creates a new immutable model object under state/models, generally these objects are referenced under on of your root models.

$optionsHeader
  --${AFGenerateUISubcommand.argTheme} The type of the theme to use, defaults to your default theme
  ${AFCommand.argPrivateOptionHelp}    
''';
  }

  

  @override
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.rawArgs;
    if(unnamed.isEmpty) {
      throwUsageError("Expected at least one argument");
    }

    final modelName = unnamed[0];

    verifyMixedCase(modelName, "model name");

    final args = parseArguments(unnamed, defaults: {
      AFGenerateUISubcommand.argTheme: ctx.generator.nameDefaultTheme
    });

    generateStateStatic(ctx, modelName, args.named);


    // replace any default 
    ctx.generator.finalizeAndWriteFiles(ctx);

  }

  static void generateStateStatic(AFCommandContext ctx, String identifier, Map<String, dynamic> args) {
    if(identifier.endsWith(AFCodeGenerator.lpiSuffix)) {
      generateLPIStatic(ctx, identifier, args);
    } else if(identifier.endsWith(AFCodeGenerator.stateViewSuffix)) {
      _generateStateViewStatic(ctx, identifier, args);
    } else {
      _generateModelStatic(ctx, identifier, args);    
    }
  }

  static void generateLPIStatic(AFCommandContext ctx, String identifier, Map<String, dynamic> args, {
    String? fullId, 
    AFLibraryID? fromLib,
    String parentType = "AFLibraryProgrammingInterface"
  }) {
    final generator = ctx.generator;

    if(!identifier.startsWith(generator.appNamespaceUpper)) {
      throw AFCommandError(error: "$identifier must start with ${generator.appNamespaceUpper}");
    }

    // create the LPI file
    final isOverride = fullId != null;
    final lpiPath = generator.pathLPI(identifier, isOverride: isOverride);
    final lpiFile = generator.createFile(ctx, lpiPath, AFUISourceTemplateID.fileLPI);
    lpiFile.replaceText(ctx, AFUISourceTemplateID.textLPIType, identifier);
    lpiFile.replaceText(ctx, AFUISourceTemplateID.textLPIParentType, parentType);
    if(fromLib != null) {
      generator.addImportFlutterFile(ctx, 
        libraryId: fromLib, 
        to: lpiFile,
        before: AFCodeRegExp.startDeclareLPI,
      );
    }    

    final idIdentifier = generator.removeSuffixAndCamel(generator.removePrefix(identifier, generator.appNamespaceUpper), "LPI");

    // create an ID for the LPI
    if(!isOverride) {
      final declareId = DeclareLPIIDStatementT().toBuffer();
      declareId.replaceText(ctx, AFUISourceTemplateID.textLPIID, idIdentifier);
      declareId.executeStandardReplacements(ctx);
      final idFile = generator.modifyFile(ctx,  generator.pathIdFile);
      final kind = "LibraryProgrammingInterface";
      final after = AFCodeRegExp.startUIID(kind, kind);
      idFile.addLinesAfter(ctx, after, declareId.lines);
    } 

    // register the LPI
    final definesFile = generator.modifyFile(ctx, generator.pathDefineCore);
    final defineLPI = DeclareDefineLPIT().toBuffer();
    defineLPI.replaceText(ctx, AFUISourceTemplateID.textLPIType, identifier);
    defineLPI.replaceText(ctx, AFUISourceTemplateID.textLPIID, fullId ?? "${generator.appNamespaceUpper}LibraryProgrammingInterfaceID.$idIdentifier");
    definesFile.addLinesAfter(ctx, AFCodeRegExp.startDefineLPI, defineLPI.lines);
    generator.addImport(ctx,
      importPath: lpiFile.importPathStatement, 
      to: definesFile, 
      before: AFCodeRegExp.startDefineCore,
    );

    if(isOverride && fromLib != null) {
      generator.addImportIDFile(ctx,
        libraryId: fromLib,
        to: definesFile,
        before: AFCodeRegExp.startDefineCore,
      );
    }

    if(!isOverride) {
      generator.addExportsForFiles(ctx, args, [lpiFile]);
    } 
  }

  
  static void _generateModelStatic(AFCommandContext ctx, String identifier, Map<String, dynamic> args) {
    
    // generate the model file itself.
    final generator = ctx.generator;
    final isRoot = identifier.endsWith(AFCodeGenerator.rootSuffix);
    final modelPath = generator.pathModel(identifier);
    final modelFile = generator.createFile(ctx, modelPath, AFUISourceTemplateID.fileModel);
    modelFile.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);

    if(isRoot) {
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

      // this can be missing 
      if(generator.fileExists(generator.pathTestData)) {
        // add an initial test-data value
        // first, create a subprocedure for defining that kind of test data.
        final declareCallDefineTest = DeclareCallDefineTestDataT().toBuffer();
        declareCallDefineTest.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);
        
        final testDataFile = generator.modifyFile(ctx, generator.pathTestData);
        testDataFile.addLinesAfter(ctx, AFCodeRegExp.startDefineTestData, declareCallDefineTest.lines);

        final declareDefineTestData  = DeclareDefineDefineTestDataT().toBuffer();
        declareDefineTestData.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);
        declareDefineTestData.executeStandardReplacements(ctx);

        // then, declare the function that we just called.
        testDataFile.addLinesAtEnd(ctx, declareDefineTestData.lines);

        // need to import the model itself.
        generator.addImport(ctx, 
          importPath: modelFile.importPathStatement, 
          to: testDataFile, 
          before: AFCodeRegExp.startDefineTestData
        );
        
        // finally, add the id we are using.
        final declareTestID = DeclareTestIDT().toBuffer();
        declareTestID.replaceText(ctx, AFUISourceTemplateID.textTestID, "stateFullLogin$identifier");

        final idFile = generator.modifyFile(ctx, generator.pathIdFile);
        idFile.addLinesAfter(ctx, AFCodeRegExp.startDeclareTestDataID, declareTestID.lines);

        // then, add in the new test data to the full signed in state.
        final declareInitTestData = DeclareReferenceTestDataT().toBuffer();
        declareInitTestData.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);
        declareInitTestData.executeStandardReplacements(ctx);
        testDataFile.addLinesAfter(ctx, AFCodeRegExp.startDeclareTestData, declareInitTestData.lines);
      }

      // we need to add it to the default state view access
      final pathStateViewAccess = generator.pathStateViewAccess();
      final accessFile = generator.modifyFile(ctx, pathStateViewAccess);
      final regexMixinStart = AFCodeRegExp.startMixinStateAccess;
      final declareAccess = DeclareModelAccessStatementT().toBuffer();
      var identifierNoRoot = identifier;
      if(identifierNoRoot.endsWith("Root")) {
        identifierNoRoot = identifierNoRoot.substring(0, identifierNoRoot.length-4);
      }
      declareAccess.replaceText(ctx, AFUISourceTemplateID.textModelName, identifier);
      declareAccess.replaceText(ctx, AFUISourceTemplateID.textModelNameNoRoot, identifierNoRoot);
      accessFile.addLinesAfter(ctx, regexMixinStart, declareAccess.lines);

      final declareImport = ImportFromPackage().toBuffer();
      declareImport.replaceText(ctx, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
      declareImport.replaceText(ctx, AFUISourceTemplateID.textPackagePath, modelFile.importPathStatement);
      
      accessFile.addImports(ctx, declareImport.lines);
    }

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
    final theme = args[AFGenerateUISubcommand.argTheme];
    final stateViewFile = generator.createFile(ctx, stateViewPath, AFUISourceTemplateID.fileStateView);
    stateViewFile.replaceText(ctx, AFUISourceTemplateID.textStateViewName, identifier);
    stateViewFile.replaceText(ctx, AFUISourceTemplateID.textThemeType, theme);
    stateViewFile.replaceText(ctx, AFUISourceTemplateID.textStateViewPrefix, generator.removeSuffix(identifier, AFCodeGenerator.stateViewSuffix));
    stateViewFile.executeStandardReplacements(ctx);

    final imports = <String>[];
    // if we can find the specified theme, then we need to import it.
    final pathTheme = generator.pathTheme(theme, isCustomParent: false);
    if(pathTheme != null) {
      generator.addImportsForPath(ctx, pathTheme, imports: imports, requireExists: false);    
    }

    stateViewFile.addImports(ctx, imports);

    generator.addExportsForFiles(ctx, args, [
      stateViewFile
    ]);

  }

}
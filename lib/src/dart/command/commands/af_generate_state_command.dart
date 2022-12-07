

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/files/state_view.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_initial_state_model_function.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_define_test_data.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_lpi.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_initial_value.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_lpi_id_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_model_access_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_reference_test_data.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_test_id.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFGenerateStateSubcommand extends AFGenerateSubcommand {
  static const nameCountInStateRoot = "CountInStateRoot";

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

  static void generateLPIStatic(AFCommandContext context, String identifier, Map<String, dynamic> args, {
    String? fullId, 
    AFLibraryID? fromLib,
    String parentType = "AFLibraryProgrammingInterface"
  }) {
    final generator = context.generator;

    if(!identifier.startsWith(generator.appNamespaceUpper)) {
      throw AFCommandError(error: "$identifier must start with ${generator.appNamespaceUpper}");
    }

    // create the LPI file
    final isOverride = fullId != null;
    final lpiPath = generator.pathLPI(identifier, isOverride: isOverride);
    final lpiFile = context.createFile(lpiPath, LPIT(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      AFSourceTemplate.insertMainParentTypeInsertion: parentType
    });

    if(fromLib != null) {
      generator.addImportFlutterFile(context, 
        libraryId: fromLib, 
        to: lpiFile,
      );
    }    

    final idIdentifier = generator.removeSuffixAndCamel(generator.removePrefix(identifier, generator.appNamespaceUpper), "LPI");

    // create an ID for the LPI
    if(!isOverride) {
      final declareId = DeclareLPIIDStatementT().toBuffer(context);
      declareId.replaceText(context, AFUISourceTemplateID.textLPIID, idIdentifier);
      declareId.executeStandardReplacements(context);
      final idFile = generator.modifyFile(context,  generator.pathIdFile);
      final kind = "LibraryProgrammingInterface";
      final after = AFCodeRegExp.startUIID(kind, kind);
      idFile.addLinesAfter(context, after, declareId.lines);
    } 

    // register the LPI
    final definesFile = generator.modifyFile(context, generator.pathDefineCore);
    final defineLPI = DeclareDefineLPIT().toBuffer(context);
    defineLPI.replaceText(context, AFUISourceTemplateID.textLPIType, identifier);
    defineLPI.replaceText(context, AFUISourceTemplateID.textLPIID, fullId ?? "${generator.appNamespaceUpper}LibraryProgrammingInterfaceID.$idIdentifier");
    definesFile.addLinesAfter(context, AFCodeRegExp.startDefineLPI, defineLPI.lines);
    generator.addImport(context,
      importPath: lpiFile.importPathStatement, 
      to: definesFile, 
    );

    if(isOverride && fromLib != null) {
      generator.addImportIDFile(context,
        libraryId: fromLib,
        to: definesFile,
      );
    }

    if(!isOverride) {
      generator.addExportsForFiles(context, args, [lpiFile]);
    } 
  }

  
  static void _generateModelStatic(AFCommandContext context, String identifier, Map<String, dynamic> args) {
    
    // generate the model file itself.
    final generator = context.generator;
    final isRoot = identifier.endsWith(AFCodeGenerator.rootSuffix);
    final modelPath = generator.pathModel(identifier);
    final modelFile = context.createFile(modelPath, ModelT.core(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      AFSourceTemplate.insertAdditionalMethodsInsertion: isRoot ? SnippetInitialStateModelFunctionT() : AFSourceTemplate.empty,
    });

    if(isRoot) {
      // add it to the root application state
      final pathState = generator.pathAppState;
      final stateFile = generator.modifyFile(context, pathState);
      generator.addImport(context,
        importPath: modelFile.importPathStatement,
        to: stateFile,
      );

      // add its initial value to the state
      final declareInitialValue = DeclareInitialValueT().toBuffer(context);
      declareInitialValue.replaceText(context, AFUISourceTemplateID.textModelName, identifier);
      stateFile.addLinesAfter(context, AFCodeRegExp.startReturnInitialState, declareInitialValue.lines);

      // this can be missing 
      if(generator.fileExists(generator.pathTestData)) {
        // add an initial test-data value
        // first, create a subprocedure for defining that kind of test data.
        final declareCallDefineTest = DeclareCallDefineTestDataT().toBuffer(context);
        declareCallDefineTest.replaceText(context, AFUISourceTemplateID.textModelName, identifier);
        
        final testDataFile = generator.modifyFile(context, generator.pathTestData);
        testDataFile.addLinesAfter(context, AFCodeRegExp.startDefineTestData, declareCallDefineTest.lines);

        var declareDefineTestData = context.createSnippet(SnippetDefineTestDataT.core(), insertions: {
          SnippetDefineTestDataT.insertModelName: identifier,
        });
        

        // then, declare the function that we just called.
        testDataFile.addLinesAtEnd(context, declareDefineTestData.lines);

        // need to import the model itself.
        generator.addImport(context, 
          importPath: modelFile.importPathStatement, 
          to: testDataFile, 
        );
        
        context.createDeclareId("${generator.appNamespaceUpper}TestDataID.stateFullLogin$identifier");

        // then, add in the new test data to the full signed in state.
        final declareInitTestData = DeclareReferenceTestDataT().toBuffer(context);
        declareInitTestData.replaceText(context, AFUISourceTemplateID.textModelName, identifier);
        declareInitTestData.executeStandardReplacements(context);
        testDataFile.addLinesAfter(context, AFCodeRegExp.startDeclareTestData, declareInitTestData.lines);
      }

      // we need to add it to the default state view access
      final pathStateViewAccess = generator.pathStateViewAccess();
      final accessFile = generator.modifyFile(context, pathStateViewAccess);
      final regexMixinStart = AFCodeRegExp.startMixinStateAccess;
      final declareAccess = DeclareModelAccessStatementT().toBuffer(context);
      var identifierNoRoot = identifier;
      if(identifierNoRoot.endsWith("Root")) {
        identifierNoRoot = identifierNoRoot.substring(0, identifierNoRoot.length-4);
      }
      declareAccess.replaceText(context, AFUISourceTemplateID.textModelName, identifier);
      declareAccess.replaceText(context, AFUISourceTemplateID.textModelNameNoRoot, identifierNoRoot);
      accessFile.addLinesAfter(context, regexMixinStart, declareAccess.lines);

      final declareImport = ImportFromPackage().toBuffer(context);
      declareImport.replaceText(context, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
      declareImport.replaceText(context, AFUISourceTemplateID.textPackagePath, modelFile.importPathStatement);
      
      accessFile.addImports(context, declareImport.lines);
    }

    // export it
    generator.addExportsForFiles(context, args, [
      modelFile
    ]);

  }

  static void _generateStateViewStatic(AFCommandContext context, String identifier, Map<String, dynamic> args) {
    final generator = context.generator;
    if(!identifier.startsWith(generator.appNamespaceUpper)) {
      throw AFCommandError(error: "$identifier must begin with ${generator.appNamespaceUpper}");
    }

    final stateViewPath = generator.pathStateView(identifier);

    if(stateViewPath == null) {
      throw AFCommandError(error: "Invalid identifier $identifier");
    }
    final theme = args[AFGenerateUISubcommand.argTheme];
    final stateViewFile = context.createFile(stateViewPath, StateViewT(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      StateViewT.insertThemeType: theme,
      StateViewT.insertStateViewPrefix: generator.removeSuffix(identifier, AFCodeGenerator.stateViewSuffix)
    });

    final imports = <String>[];
    // if we can find the specified theme, then we need to import it.
    final pathTheme = generator.pathTheme(theme, isCustomParent: false);
    if(pathTheme != null) {
      generator.addImportsForPath(context, pathTheme, imports: imports, requireExists: false);    
    }

    stateViewFile.addImports(context, imports);

    generator.addExportsForFiles(context, args, [
      stateViewFile
    ]);

  }

}
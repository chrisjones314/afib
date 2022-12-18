

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/lpi.t.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/core/files/state_view.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_define_lpi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_define_test_data.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_find_test_data.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_lpi_id.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_model_accessor.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_test_data.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_initial_state_model_function.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_invoke_initial_state.t.dart';

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
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp
  ${AFCommand.argPrivateOptionHelp}    
''';
  }

  

  @override
  Future<void> execute(AFCommandContext context) async {

    final args = context.parseArguments(
      command: this, 
      unnamedCount: 1, 
      named: {
        AFGenerateUISubcommand.argTheme: context.generator.nameDefaultTheme
      }
    );

    final modelName = args.accessUnnamedFirst;

    verifyMixedCase(modelName, "model name");
    generateStateStatic(context, modelName, args);

    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }

  static void generateStateStatic(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) {
    if(identifier.endsWith(AFCodeGenerator.lpiSuffix)) {
      generateLPIStatic(context, identifier, args);
    } else if(identifier.endsWith(AFCodeGenerator.stateViewSuffix)) {
      _generateStateViewStatic(context, identifier, args);
    } else {
      _generateModelStatic(context, identifier, args);    
    }
  }

  static void generateLPIStatic(AFCommandContext context, String identifier, AFCommandArgumentsParsed args, {
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
    final lpiFile = context.createFile(lpiPath, LPIT.core(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      AFSourceTemplate.insertMainParentTypeInsertion: parentType
    });

    if(fromLib != null) {
      lpiFile.importFlutterFile(context, fromLib);
    }    

    final idIdentifier = generator.removeSuffixAndCamel(generator.removePrefix(identifier, generator.appNamespaceUpper), "LPI");

    // create an ID for the LPI
    if(!isOverride) {
      final declareId = context.createSnippet(SnippetDeclareLPIIDT(), insertions: {
        SnippetCallDefineLPIT.insertLPIID: idIdentifier,
      });
      final idFile = generator.modifyFile(context,  generator.pathIdFile);
      final kind = "LibraryProgrammingInterface";
      final after = AFCodeRegExp.startUIID(kind, kind);
      idFile.addLinesAfter(context, after, declareId.lines);
    } 

    // register the LPI
    final definesFile = generator.modifyFile(context, generator.pathDefineCore);
    final defineLPI = context.createSnippet(SnippetCallDefineLPIT(), insertions: {
      SnippetCallDefineLPIT.insertLPIID: fullId ?? "${generator.appNamespaceUpper}LibraryProgrammingInterfaceID.$idIdentifier",
      SnippetCallDefineLPIT.insertLPIType: identifier,
    });
    definesFile.addLinesAfter(context, AFCodeRegExp.startDefineLPI, defineLPI.lines);
    definesFile.importFile(context, lpiFile);

    if(isOverride && fromLib != null) {
      definesFile.importIDFile(context, fromLib);
    }

    if(!isOverride) {
      generator.addExportsForFiles(context, args, [lpiFile]);
    } 
  }

  
  static void _generateModelStatic(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) {
    
    // generate the model file itself.
    final generator = context.generator;
    final isRoot = identifier.endsWith(AFCodeGenerator.rootSuffix);
    final modelPath = generator.pathModel(identifier);
    var identifierNoRoot = identifier;
    if(identifierNoRoot.endsWith("Root")) {
      identifierNoRoot = identifierNoRoot.substring(0, identifierNoRoot.length-4);
    }

    final modelInsertions = context.coreInsertions.reviseAugment({
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      AFSourceTemplate.insertMainTypeNoRootInsertion: identifierNoRoot,
    });


    final modelFile = context.createFile(modelPath, ModelT.core(), extend: modelInsertions, insertions: {
      AFSourceTemplate.insertAdditionalMethodsInsertion: isRoot ? SnippetInitialStateModelFunctionT() : AFSourceTemplate.empty,
    });

    if(isRoot) {
      // add it to the root application state
      final pathState = generator.pathAppState;
      final stateFile = generator.modifyFile(context, pathState);
      stateFile.importFile(context, modelFile);

      // add its initial value to the state
      final declareInitialValue = context.createSnippet(SnippetInvokeInitialStateT(), extend: modelInsertions);
      stateFile.addLinesAfter(context, AFCodeRegExp.startReturnInitialState, declareInitialValue.lines);

      // this can be missing 
      if(generator.fileExists(generator.pathTestData)) {
        // add an initial test-data value
        // first, create a subprocedure for defining that kind of test data.
        final declareCallDefineTest = context.createSnippet(SnippetCallDefineTestDataT(), insertions: {
          AFSourceTemplate.insertMainTypeInsertion: identifier,
        });
        
        final testDataFile = generator.modifyFile(context, generator.pathTestData);
        testDataFile.addLinesAfter(context, AFCodeRegExp.startDefineTestData, declareCallDefineTest.lines);

        var declareDefineTestData = context.createSnippet(SnippetDefineTestDataT.core(), extend: modelInsertions);
        
        // then, declare the function that we just called.
        testDataFile.addLinesAtEnd(context, declareDefineTestData.lines);
        testDataFile.importAll(context, declareDefineTestData.extraImports);

        // need to import the model itself.
        testDataFile.importFile(context, modelFile);
        
        context.createDeclareId("${generator.appNamespaceUpper}TestDataID.stateFullLogin$identifier");


        // then, add in the new test data to the full signed in state.
        final declareInitTestData = context.createSnippet(SnippetCallFindTestDataT(), extend: modelInsertions);
        testDataFile.addLinesAfter(context, AFCodeRegExp.startDeclareTestData, declareInitTestData.lines);
      }

      // we need to add it to the default state view access
      final pathStateViewAccess = generator.pathStateViewAccess();
      final accessFile = generator.modifyFile(context, pathStateViewAccess);
      final regexMixinStart = AFCodeRegExp.startMixinStateAccess;
      final declareAccess = context.createSnippet(SnippetDeclareModelAccessorT(), extend: modelInsertions);
      accessFile.addLinesAfter(context, regexMixinStart, declareAccess.lines);

      final declareImport = SnippetImportFromPackageT().toBuffer(context, insertions: {
        AFSourceTemplate.insertPackagePathInsertion: modelFile.importPathStatement
      });
      
      accessFile.importAll(context, declareImport.lines);
    }

    // export it
    generator.addExportsForFiles(context, args, [
      modelFile
    ]);

  }

  static void _generateStateViewStatic(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) {
    final generator = context.generator;
    if(!identifier.startsWith(generator.appNamespaceUpper)) {
      throw AFCommandError(error: "$identifier must begin with ${generator.appNamespaceUpper}");
    }

    final stateViewPath = generator.pathStateView(identifier);

    if(stateViewPath == null) {
      throw AFCommandError(error: "Invalid identifier $identifier");
    }
    final theme = args.accessNamed(AFGenerateUISubcommand.argTheme);
    final stateViewFile = context.createFile(stateViewPath, StateViewT(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      StateViewT.insertThemeType: theme,
      StateViewT.insertStateViewPrefix: generator.removeSuffix(identifier, AFCodeGenerator.stateViewSuffix)
    });

    // if we can find the specified theme, then we need to import it.
    final pathTheme = generator.pathTheme(theme, isCustomParent: false);
    if(pathTheme != null) {
      stateViewFile.importProjectPath(context, pathTheme);
    }

    generator.addExportsForFiles(context, args, [
      stateViewFile
    ]);

  }

}
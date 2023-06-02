

import 'package:afib/afib_command.dart';
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
import 'package:afib/src/dart/command/templates/core/snippets/snippet_serial_methods.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_root_methods.t.dart';

/// The class that handles 'generate state...'
class AFGenerateStateSubcommand extends AFGenerateSubcommand {
  static const argNotSerial = "no-serial-methods";
  static const argNoReviseMethods = "no-revise-methods";
  static const argAddStandardRoot = "add-standard-root";

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
  For Root States or Simple Models
    ${AFGenerateSubcommand.argMemberVariablesHelp} 
      Note: If your backend store has integer ids, specify "int id;" as your id, AFib will automatically convert to/from a string on the client.
    ${AFGenerateSubcommand.argResolveVariablesHelp}

  For Simple Models Only
    --$argAddStandardRoot - Add if you want to also generate a standard root containing a map of String ids to objects of this model.
    --$argNoReviseMethods - Include if you do not want to generate default revise methods for each member variable 
    --$argNotSerial - Include if you do not want to generate standard serialization methods
  
  For State Views
    --${AFGenerateUISubcommand.argTheme} The type of the theme to use, defaults to your default theme

  Standard Options
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
        AFGenerateUISubcommand.argTheme: context.generator.nameDefaultTheme,
        argNotSerial: "false",
        argNoReviseMethods: "false",
        AFGenerateSubcommand.argMemberVariables: "",
        AFGenerateSubcommand.argResolveVariables: "",
        AFGenerateStateSubcommand.argAddStandardRoot: "false",
      }
    );

    final modelName = args.accessUnnamedFirst;
    verifyNotGenerateConflict(modelName, [AFGenerateQuerySubcommand.suffixQuery], "state");
    verifyNotGenerateConflict(modelName, AFGenerateUISubcommand.allUISuffixes, "state");

    verifyMixedCase(modelName, "model name");
    await generateStateStatic(context, modelName, args);

    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }

  Future<void> generateStateStatic(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) async {
    if(identifier.endsWith(AFCodeGenerator.lpiSuffix)) {
      generateLPIStatic(context, identifier, args);
    } else if(identifier.endsWith(AFCodeGenerator.stateViewSuffix)) {
      _generateStateViewStatic(context, identifier, args);
    } else {
      await _generateModelStatic(context, identifier, args);    
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
      const kind = "LibraryProgrammingInterface";
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

  
  Future<void> _generateModelStatic(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) async {
    
    // generate the model file itself.
    final generator = context.generator;
    final isRoot = identifier.endsWith(AFCodeGenerator.rootSuffix);
    final modelPath = generator.pathModel(identifier);
    if(modelPath == null) {
      throw AFException("Internal exception, conversion from model to path failed.");
    }
    final isAddStandardRoot = args.accessNamedFlag(AFGenerateStateSubcommand.argAddStandardRoot);
    var identifierNoRoot = identifier;
    var identifierNoRootOriginal = identifier;
    if(identifierNoRoot.endsWith("Root")) {
      identifierNoRoot = identifierNoRoot.substring(0, identifierNoRoot.length-4);
      identifierNoRootOriginal = identifierNoRoot;
    }
    final argAddStandard = args.accessNamed(argAddStandardRoot);
    if(argAddStandard != "true" && isRoot) {
      identifierNoRoot = argAddStandard;
    }

    final modelInsertions = context.coreInsertions.reviseAugment({
      AFSourceTemplate.insertMainTypeInsertion: identifier,
      AFSourceTemplate.insertMainTypeNoRootInsertion: identifierNoRoot,
    });

    var memberVariables = context.memberVariables(context, args, identifier);

    Object snippetSerial = AFSourceTemplate.empty;
    Object serialConstants = AFSourceTemplate.empty;
    Object standardReviseMethods = AFSourceTemplate.empty;
    Object superclassSyntax = AFSourceTemplate.empty;
    Object standardRootMethods = AFSourceTemplate.empty;
    Object superCall = AFSourceTemplate.empty;
    if(isRoot && isAddStandardRoot) {
      memberVariables ??= AFMemberVariableTemplates.createEmpty(mainType: identifier);
      memberVariables.setStandardRootMapType(identifierNoRoot);

      superclassSyntax = "extends AFStandardIDMapRoot<$identifier, $identifierNoRoot>";
      standardRootMethods = context.createSnippet(SnippetStandardRootMethodsT(), extend: modelInsertions);
      superCall = ": super(items: items)";
    }

    final isRootWithAddStandardRoot = isRoot && isAddStandardRoot;
    if(memberVariables != null && !args.accessNamedFlag(AFGenerateStateSubcommand.argNotSerial) && !isRootWithAddStandardRoot) {
      snippetSerial = context.createSnippet(SnippetSerialMethodsT.core(
        serializeFrom: memberVariables.serializeFrom, 
        serializeTo: memberVariables.serializeTo
      ));
      serialConstants = memberVariables.serialConstants;
    }
    if(memberVariables != null && !args.accessNamedFlag(AFGenerateStateSubcommand.argNoReviseMethods)) {
      standardReviseMethods = memberVariables.reviseMethods;
    }

    final memberVariableImports = memberVariables?.extraImports(context) ?? AFSourceTemplate.empty;

    final modelt = ModelT.core(
      isRoot: isRoot,      
      memberVariables: memberVariables?.declareVariables,
      constructorParams: memberVariables?.constructorParams,
      copyWithParams: memberVariables?.copyWithParams,
      copyWithCall: memberVariables?.copyWithCall,
      serialMethods: snippetSerial,
      serialConstants: serialConstants,
      memberVariableImports: memberVariableImports,
      standardReviseMethods: standardReviseMethods,
      standardRootMethods: standardRootMethods,
      superclassSyntax: superclassSyntax,
      superCall: superCall,
      resolveFunctions: memberVariables?.resolveMethods,
    );

    final modelFile = context.createFile(modelPath, modelt, extend: modelInsertions, insertions: {
      AFSourceTemplate.insertMemberVariablesInsertion: memberVariables?.declareVariables ?? AFSourceTemplate.empty,
      AFSourceTemplate.insertConstructorParamsInsertion: memberVariables?.constructorParams ?? AFSourceTemplate.empty,
      AFSourceTemplate.insertCopyWithParamsInsertion: memberVariables?.copyWithParams ?? AFSourceTemplate.empty,
      AFSourceTemplate.insertCopyWithCallInsertion: memberVariables?.copyWithCall ?? AFSourceTemplate.empty,      
      ModelT.insertSerialConstantsInsertion: serialConstants,
      ModelT.insertSerialMethodsInsertion: snippetSerial,
      ModelT.insertInitialState: isRoot ? SnippetInitialStateModelFunctionT(
        initialStateParams: memberVariables?.initialValueDeclaration ?? AFSourceTemplate.empty,
      ) : AFSourceTemplate.empty,
      AFSourceTemplate.insertMemberVariableImportsInsertion: memberVariableImports,
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
      final declareAccess = context.createSnippet(SnippetDeclareModelAccessorT.core(), extend: modelInsertions, insertions: {
        AFSourceTemplate.insertMainTypeNoRootInsertion: identifierNoRootOriginal,
      });
      accessFile.addLinesAfter(context, regexMixinStart, declareAccess.lines);
      accessFile.importAll(context, declareAccess.extraImports);

      final declareImport = SnippetImportFromPackageT().toBuffer(context, insertions: {
        AFSourceTemplate.insertPackagePathInsertion: modelFile.importPathStatement
      });
      
      accessFile.importAll(context, declareImport.lines);
    }

    // export it
    generator.addExportsForFiles(context, args, [
      modelFile
    ]);

    // if this is a model, and they want a standard root, then we need to forumulate a sub-command to generate it.
    if(!isRoot && isAddStandardRoot) {
      final pluralIdentifier = AFCodeGenerator.pluralize(identifier);
      final cmd = "generate state ${pluralIdentifier}Root --$argAddStandardRoot $identifier";
      await context.executeSubCommand(cmd, context.coreInsertions);
    }

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
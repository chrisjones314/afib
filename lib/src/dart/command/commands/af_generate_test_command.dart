

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/state_test.t.dart';
import 'package:afib/src/dart/command/templates/core/files/unit_test.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_unit_test.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_state_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_unit_test_impl.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFGenerateTestSubcommand extends AFGenerateSubcommand {
  static const argExtendTest = 'extend-test';

  AFGenerateTestSubcommand();
  
  @override
  String get description => "Generate a test";

  @override
  String get name => "test";

  @override 
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate test [Your${AFCodeGenerator.unitTestSuffix}|Your${AFCodeGenerator.stateTestSuffix}] [any --options]

$descriptionHeader
  If your identifier ends with ${AFCodeGenerator.unitTestSuffix}, creates a new unit test.
  If your identifier ends with ${AFCodeGenerator.stateTestSuffix}, creates a new state test.

$optionsHeader
  --$argExtendTest - (optional) For state test, the fully qualified ID of the state test you are extending, eg. ${AFibD.config.appNamespace.toUpperCase()}StateTestID.yourParent
  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp
  ${AFCommand.argPrivateOptionHelp}    
''';
  }

  @override
  void execute(AFCommandContext context) {

    final args = context.parseArguments(
      command: this, 
      unnamedCount: 1, 
      named: {
        argExtendTest: "null",
      }
    );

    final testName = args.accessUnnamedFirst;

    verifyMixedCase(testName, "test name");
    generateTestStatic(context, testName, args);

    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }

  static void generateTestStatic(AFCommandContext ctx, String identifier, AFCommandArgumentsParsed args) {
    if(identifier.endsWith(AFCodeGenerator.unitTestSuffix)) {
      generateUnitTest(ctx, identifier, args);
    } else if(identifier.endsWith(AFCodeGenerator.stateTestSuffix)) {
      generateStateTest(ctx, identifier, args);
    } else {
      throw AFException("Epected $identifier to end with ${AFCodeGenerator.stateTestSuffix} or ${AFCodeGenerator.unitTestSuffix}");
    }
  }

  static AFGeneratedFile _generateTest(AFCommandContext context, String identifier, AFCommandArgumentsParsed args, {
    required String suffix,
    required AFFileSourceTemplate testFile,
    required AFCodeBuffer unitTestImpl,
  }) {
    final generator = context.generator;
    final identifierShort = generator.removeSuffix(identifier, suffix);
    final identifierShortCamel = generator.removeSuffixAndCamel(identifier, suffix);

    final extendTest = args.accessNamed(argExtendTest);

    final unitTestFile = context.createFile(generator.pathTest(identifier, suffix), testFile, insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: "",
      UnitTestT.insertTestName: identifierShort,
      UnitTestT.insertUnitTestCode: unitTestImpl,
      StateTestT.insertExtendTestId: extendTest,
    });

    // create the id.
    context.createDeclareId("${generator.appNamespaceUpper}${suffix}ID.$identifierShortCamel");

    // call the test file's define function from the main unit tests file.
    final unitTestsFile = generator.modifyFile(context, generator.pathTests(suffix));
    final callUnitTest = context.createSnippet(SnippetCallUnitTestT(), insertions: {
      SnippetCallUnitTestT.insertTestName: identifierShort,
    });

    unitTestsFile.addLinesAfter(context, AFCodeRegExp.startDefineTestsFunction(suffix), callUnitTest.lines);
    generator.addImport(context,
      importPath: unitTestFile.importPathStatement, 
      to: unitTestsFile, 
    );

    return unitTestFile;
  }



  static void generateUnitTest(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) {

    final unitTestImpl = context.createSnippet(SnippetUnitTestImplT());
    
    // create the test file.
    _generateTest(context, identifier, args, 
      suffix: AFCodeGenerator.unitTestSuffix,
      testFile: UnitTestT.core(),
      unitTestImpl: unitTestImpl,
    );

  }
  
  static void generateStateTest(AFCommandContext context, String identifier, AFCommandArgumentsParsed args) {

    final stateTestImpl = context.createSnippet(SnippetStateTestImplT());

    _generateTest(context, identifier, args, 
      suffix: AFCodeGenerator.stateTestSuffix,
      testFile: StateTestT.core(),
      unitTestImpl: stateTestImpl,
    );
    
  }

}
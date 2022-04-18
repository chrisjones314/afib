
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_screen_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_screen_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_with_spi_no_back.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_spi_impls.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// Parent for commands executed through the afib command line app.
class AFCreateAppCommand extends AFCommand { 
  static const kindApp = "app";
  static const kindUILibrary = "ui_library";

  final String name = "create";
  final String description = "Install afib framework support into an existing flutter app project";

  String get usage {
    return '''
Usage 
  afib_bootstrap.dart create [$kindApp|$kindUILibrary] yourpackagename YPC

Description
  $description

Options
  $kindApp - Install to create a full app
  $kindUILibrary - Install to create a UI library which exports screens, state, and queries for use in apps
  
  yourpackage - the full identifier for your package, all lowercase.   This is the value from your pubspec.yaml's
    name field, which should be in the folder you are running this command from. 
  YPC - a 2-5 digit the code/prefix for your app, all uppercase.  For example, for the AFib Signin library this is AFSI (
    note that you should not prefix yours with AF)
''';
  }


  AFCreateAppCommand();

  void run(AFCommandContext ctx) {
    // override this to avoid 'error not in root of project'
    execute(ctx);
  }


  void execute(AFCommandContext ctx) {
    // first, determine the base path.
    final args = ctx.arguments.rest;
    if(args.length < 4) {
      throwUsageError("Expected at leat four arguments");
    }

    final kind = args[1];
    final packageName = args[2];
    final packageCode = args[3];

    if(kind != kindApp && kind != kindUILibrary) {
      throwUsageError("Expected kind to be $kindApp or $kindUILibrary");
    }

    verifyAllLowercase(packageCode);
    verifyAllLowercase(packageName);
    AFibD.registerGlobals();

    AFibD.config.putInternal(AFConfigEntries.appNamespace, packageCode);
    AFibD.config.putInternal(AFConfigEntries.packageName, packageName);
    AFibD.config.putInternal(AFConfigEntries.environment, AFEnvironment.debug);


    final generator = ctx.generator;
    _verifyPubspec(ctx, packageName);

    _createAppCommand(ctx);
    _createStandardFile(ctx, generator.pathAppId, AFUISourceTemplateID.fileAppcodeID);
    _createInitializationFiles(ctx);
    _createQueryFiles(ctx);
    _createStateFiles(ctx);
    _createTestFiles(ctx);
    _createUIFiles(ctx);
    
    _createMainFiles(ctx);

    generator.finalizeAndWriteFiles(ctx);
  }

  void _createUIFiles(AFCommandContext ctx) {
    final generator = ctx.generator;
    _createStandardFile(ctx, generator.pathConnectedBaseFile, AFUISourceTemplateID.fileConnectedBase);
    _createStandardFile(ctx, generator.pathDefaultTheme, AFUISourceTemplateID.fileDefaultTheme);
    _createStandardFile(ctx, generator.pathScreenMap, AFUISourceTemplateID.fileScreenMap);
    _createStandardFile(ctx, generator.pathFundamentalTheme, AFUISourceTemplateID.fileFundamentalTheme);

    final args = {
      AFGenerateScreenSubcommand.argStateView: generator.nameDefaultStateView,
      AFGenerateScreenSubcommand.argTheme: generator.nameDefaultTheme,
      AFCommand.argPrivate: false,
    };

    AFGenerateScreenSubcommand.createScreen(ctx, "StartupScreen", args,
      buildWithSPI: DeclareScreenBuildWithSPINoBackImplT(),
      buildBody: DeclareDemoScreenBuildBodyT(),
      spiImpls: DeclareDemoScreenSPIImplsT(),
      screenImpls: DeclareDemoScreenScreenImplsT(),
      routeParamImpls: DeclareDemoScreenRouteParamImplsT());
  }

  void _createStateFiles(AFCommandContext ctx) {
    final generator = ctx.generator;

    _createStandardFile(ctx, generator.pathStateModelAccess, AFUISourceTemplateID.fileStateModelAccess);
    _createStandardFile(ctx, generator.pathAppState, AFUISourceTemplateID.fileState);

    final args = { 
      AFCommand.argPrivate: false,
      AFGenerateScreenSubcommand.argTheme: ctx.generator.nameDefaultTheme
    };
    
    AFGenerateStateSubcommand.generateStateStatic(ctx, ctx.generator.nameDefaultStateView, args);
  }

  void _createQueryFiles(AFCommandContext ctx) {
    final generator = ctx.generator;
    final createQueryArgs = {
      AFGenerateQuerySubcommand.argResultModelType: "AFUnused",
      AFGenerateQuerySubcommand.argRootStateType: generator.nameRootState,
    };

    AFGenerateQuerySubcommand.createQuery(
      ctx: ctx,
      queryKind: AFGenerateQuerySubcommand.kindSimple,
      queryName: generator.nameStartupQuery,
      usage: usage,
      args: createQueryArgs,
    );
  }

  void _createTestFiles(AFCommandContext ctx) {
    final generator = ctx.generator;

    generator.renameExistingFileToOld(ctx, generator.pathOriginalWidgetTest);
    _createStandardFile(ctx, generator.pathMainAFibTest, AFUISourceTemplateID.fileMainAFibTest);
    _createStandardFile(ctx, generator.pathTestData, AFUISourceTemplateID.fileTestData);
    _createStandardFile(ctx, generator.pathStateTestShortcutsFile, AFUISourceTemplateID.fileStateTestShortcuts);
    
    _createTestDefinitionFile(ctx, "Wireframe");
    _createTestDefinitionFile(ctx, "UIPrototype", filename: "ui_prototype");
    _createTestDefinitionFile(ctx, "StateTest");
    _createTestDefinitionFile(ctx, "UnitTest");

  }

  AFGeneratedFile _createTestDefinitionFile(AFCommandContext ctx, String kind, { String? filename }) {
    final generator = ctx.generator;
    final file = _createStandardFile(ctx, generator.pathTestDefinitions(filename ?? AFCodeGenerator.convertMixedToSnake(kind)), AFUISourceTemplateID.fileDefineTests);
    file.replaceText(ctx, AFUISourceTemplateID.textTestKind, kind);
    return file;
  }

  void _createMainFiles(AFCommandContext ctx) {
    final generator = ctx.generator;
    generator.renameExistingFileToOld(ctx, generator.pathMain);
    _createStandardFile(ctx, generator.pathMain, AFUISourceTemplateID.fileMain);
    _createStandardFile(ctx, generator.pathApp, AFUISourceTemplateID.fileApp);
  }

  void _createInitializationFiles(AFCommandContext ctx) {
    final generator = ctx.generator;
    _createStandardFile(ctx, generator.pathExtendBase, AFUISourceTemplateID.fileExtendBase);
    _createStandardFile(ctx, generator.pathExtendThirdPartyBase, AFUISourceTemplateID.fileExtendBaseThirdParty);
    _createStandardFile(ctx, generator.pathExtendCommand, AFUISourceTemplateID.fileExtendCommand);
    _createStandardFile(ctx, generator.pathExtendThirdPartyCommand, AFUISourceTemplateID.fileExtendCommandThirdParty);
    _createStandardFile(ctx, generator.pathExtendThirdPartyUI, AFUISourceTemplateID.fileExtendThirdParty);
    _createStandardFile(ctx, generator.pathExtendApplication, AFUISourceTemplateID.fileExtendApplication);
    _createStandardFile(ctx, generator.pathExtendApp, AFUISourceTemplateID.fileExtendApp);
    _createStandardFile(ctx, generator.pathExtendTest, AFUISourceTemplateID.fileExtendTest);
    
    _createEnvironmentFile(ctx, "Debug");
    _createEnvironmentFile(ctx, "Prototype");
    _createEnvironmentFile(ctx, "Test");
    _createEnvironmentFile(ctx, "Production");
    _createStandardFile(ctx, generator.pathCreateDartParams, AFUISourceTemplateID.fileCreateDartParams);

    AFConfigCommand.updateConfig(ctx, AFibD.config, AFibD.configEntries, ctx.arguments);
    AFConfigCommand.writeUpdatedConfig(ctx);
  }

  AFGeneratedFile _verifyPubspec(AFCommandContext ctx, String packageName) {
    final generator = ctx.generator;
    final pathPubspec = generator.pathPubspecYaml;
    if(!generator.fileExists(pathPubspec)) {
      throw AFCommandError(error: "The file ${pathPubspec.last} must exist in the folder from which you are running this command");
    }

    final filePubspec = generator.modifyFile(ctx, pathPubspec);
    final pubspec = filePubspec.loadPubspec();
    final name = pubspec.name;

    if(name != packageName) {
      throwUsageError("Expected yourpackagename to be $name but found $packageName");
    }

    final import = pubspec.dependencies["afib"];
    if(import == null) {
      throw AFCommandError(error: "You must update your pubspec's dependencies section to include afib");
    }
    
    return filePubspec;
  }


  AFGeneratedFile _createAppCommand(AFCommandContext ctx) {
    final generator = ctx.generator;
    final pathAppCommand = generator.pathAppCommand;
    return _createStandardFile(ctx, pathAppCommand, AFUISourceTemplateID.fileAppcodeAFib);
  }


  AFGeneratedFile _createStandardFile(AFCommandContext ctx, List<String> path, AFUISourceTemplateID templateId) {
    final appCommandFile = ctx.generator.createFile(ctx, path, templateId);
    appCommandFile.executeStandardReplacements(ctx);
    return appCommandFile;
  }

  AFGeneratedFile _createEnvironmentFile(AFCommandContext ctx, String suffix) {
    final result = _createStandardFile(ctx, ctx.generator.pathEnvironment(suffix), AFUISourceTemplateID.fileEnvironment);
    result.replaceText(ctx, AFUISourceTemplateID.textEnvironmentName, suffix);
    return result;
  }
  
}
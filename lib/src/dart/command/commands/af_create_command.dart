
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_screen_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_spi_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_fundamental_theme_init.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_fundamental_theme_init_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_with_spi_no_back.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// Parent for commands executed through the afib command line app.
class AFCreateAppCommand extends AFCommand { 
  static const kindApp = "app";
  static const kindUILibrary = "ui_library";

  final String name = "create";
  final String description = "Install afib framework support into an existing flutter app project";

  String get usage {
    return '''
$usageHeader
  afib_bootstrap.dart create [$kindApp|$kindUILibrary] yourpackagename YPC

$descriptionHeader
  $description

$optionsHeader
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
    verifyOneOf(kind, [kindApp, kindUILibrary]);

    final isApp = kind == kindApp;
    final libKind = isApp ? "App" : "UILibrary";
    AFibD.config.setIsLibraryCommand(isLib: !isApp);
    final packageName = args[2];
    final packageCode = args[3];

    verifyAllLowercase(packageCode);
    verifyAllLowercase(packageName);
    AFibD.registerGlobals();

    AFibD.config.putInternal(AFConfigEntries.appNamespace, packageCode);
    AFibD.config.putInternal(AFConfigEntries.packageName, packageName);
    AFibD.config.putInternal(AFConfigEntries.environment, AFEnvironment.debug);


    final generator = ctx.generator;
    _verifyPubspec(ctx, packageName);

    _createStandardFolders(ctx, isApp: isApp);
    if(!isApp) {
      _createStandardLibraryFolders(ctx);
      _createLibExportsFiles(ctx);
    }
    _createAppCommand(ctx, libKind);
    createStandardFile(ctx, generator.pathAppId, AFUISourceTemplateID.fileAppcodeID);
    final extendAppId = isApp ? AFUISourceTemplateID.fileExtendApp : AFUISourceTemplateID.fileExtendAppUILibrary;
    _createInitializationFiles(ctx, extendAppId, libKind);
    _createQueryFiles(ctx);
    _createStateFiles(ctx);
    _createTestFiles(ctx, libKind);
    final mainTemplateId = isApp ? AFUISourceTemplateID.fileMain : AFUISourceTemplateID.fileMainUILibrary;
    _createMainFiles(ctx, mainTemplateId);
    final fundamentalInit = isApp ? DeclareFundamentalThemeInitT() : DeclareFundamentalThemeInitUILibraryT();
    _createUIFiles(ctx, packageName, libKind, fundamentalInit);

    if(!isApp) {
      _createInstallFiles(ctx);
    }
    

    generator.finalizeAndWriteFiles(ctx);
  }

  void _createInstallFiles(AFCommandContext ctx) {
    final generator = ctx.generator;

    // create the file and add it to the ui exports
    final fileInstallUI = createStandardFile(ctx, generator.pathInstallUI, AFUISourceTemplateID.fileInstallUI);
    final args = {
      AFCommand.argPrivate: false
    };

    generator.addExportsForFiles(ctx, args, [fileInstallUI]);

    // create the file and add it to the command exports.
    final fileInstallCommand = createStandardFile(ctx, generator.pathInstallCommand, AFUISourceTemplateID.fileInstallCommand);    
    generator.addExportsForFiles(ctx, args, [fileInstallCommand], toPath: generator.pathCommandExportsFile);
  }

  void _createUIFiles(AFCommandContext ctx, String packageName, String libKind, AFSourceTemplate defineFundamentalImpl) {
    final generator = ctx.generator;
    createStandardFile(ctx, generator.pathConnectedBaseFile, AFUISourceTemplateID.fileConnectedBase);
    final fileDefineUI = createStandardFile(ctx, generator.pathDefineUI, AFUISourceTemplateID.fileDefineUI);
    fileDefineUI.replaceText(ctx, AFUISourceTemplateID.textLibKind, libKind);
    final defineFundImpl = defineFundamentalImpl.toBuffer();
    defineFundImpl.executeStandardReplacements(ctx);
    fileDefineUI.replaceTextLines(ctx, AFUISourceTemplateID.textFundamentalThemeInit, defineFundImpl.lines);

    final argsTheme = {
      AFGenerateUISubcommand.argParentTheme: generator.nameDefaultParentTheme,
      AFGenerateUISubcommand.argParentThemeID: generator.nameDefaultParentThemeID,
      AFGenerateUISubcommand.argParentPackageName: packageName,
    };

    // create the theme
    AFGenerateUISubcommand.createTheme(ctx, "${generator.appNamespaceUpper}DefaultTheme", argsTheme);

    final args = {
      AFGenerateUISubcommand.argStateView: generator.nameDefaultStateView,
      AFGenerateUISubcommand.argTheme: generator.nameDefaultTheme,
      AFCommand.argPrivate: false,
    };

    AFGenerateUISubcommand.createScreen(ctx, "StartupScreen", args,
      buildWithSPI: DeclareScreenBuildWithSPINoBackImplT(),
      buildBody: DeclareDemoScreenBuildBodyT(),
      spiImpls: DeclareDemoScreenSPIImplsT(),
      screenImpls: DeclareDemoScreenScreenImplsT(),
      routeParamImpls: DeclareDemoScreenRouteParamImplsT());
  }

  void _createLibExportsFiles(AFCommandContext ctx) {
    final generator = ctx.generator;
    createStandardFile(ctx, generator.pathFlutterExportsFile, AFUISourceTemplateID.fileLibExports);
    createStandardFile(ctx, generator.pathCommandExportsFile, AFUISourceTemplateID.fileLibExports);
  }

  void _createStateFiles(AFCommandContext ctx) {
    final generator = ctx.generator;

    createStandardFile(ctx, generator.pathStateModelAccess, AFUISourceTemplateID.fileStateModelAccess);
    createStandardFile(ctx, generator.pathAppState, AFUISourceTemplateID.fileState);

    final args = { 
      AFCommand.argPrivate: false,
      AFGenerateUISubcommand.argTheme: ctx.generator.nameDefaultTheme
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

  void _createTestFiles(AFCommandContext ctx, String libKind) {
    final generator = ctx.generator;

    generator.renameExistingFileToOld(ctx, generator.pathOriginalWidgetTest);
    final fileMain = createStandardFile(ctx, generator.pathMainAFibTest, AFUISourceTemplateID.fileMainAFibTest);
    fileMain.replaceText(ctx, AFUISourceTemplateID.textLibKind, libKind);
    final appParam = libKind == "App" ? "extendApp: extendApp" : "extendUI: extendUI";
    fileMain.replaceText(ctx, AFUISourceTemplateID.textExtendAppParam, appParam);

    createStandardFile(ctx, generator.pathTestData, AFUISourceTemplateID.fileTestData);
    createStandardFile(ctx, generator.pathStateTestShortcutsFile, AFUISourceTemplateID.fileStateTestShortcuts);
    
    _createTestDefinitionFile(ctx, "Wireframe");
    _createTestDefinitionFile(ctx, "UIPrototype", filename: "ui_prototype");
    _createTestDefinitionFile(ctx, "StateTest");
    _createTestDefinitionFile(ctx, "UnitTest");
  }

  AFGeneratedFile _createTestDefinitionFile(AFCommandContext ctx, String kind, { String? filename }) {
    final generator = ctx.generator;
    final file = createStandardFile(ctx, generator.pathTestDefinitions(filename ?? AFCodeGenerator.convertMixedToSnake(kind)), AFUISourceTemplateID.fileDefineTests);
    file.replaceText(ctx, AFUISourceTemplateID.textTestKind, kind);
    return file;
  }

  void _createMainFiles(AFCommandContext ctx, AFUISourceTemplateID mainTemplate) {
    final generator = ctx.generator;
    generator.renameExistingFileToOld(ctx, generator.pathMain);
    createStandardFile(ctx, generator.pathMain, mainTemplate);
    createStandardFile(ctx, generator.pathApp, AFUISourceTemplateID.fileApp);
  }

  void _createInitializationFiles(AFCommandContext ctx, AFUISourceTemplateID extendAppId, String libKind) {
    final generator = ctx.generator;
    createStandardFile(ctx, generator.pathExtendBase, AFUISourceTemplateID.fileExtendBase);
    createStandardFile(ctx, generator.pathExtendLibraryBase, AFUISourceTemplateID.fileExtendBaseLibrary);
    final fileExtendCommand = createStandardFile(ctx, generator.pathExtendCommand, AFUISourceTemplateID.fileExtendCommand);
    fileExtendCommand.replaceText(ctx, AFUISourceTemplateID.textLibKind, libKind);

    createStandardFile(ctx, generator.pathExtendLibraryCommand, AFUISourceTemplateID.fileExtendCommandLibrary);
    createStandardFile(ctx, generator.pathExtendLibraryUI, AFUISourceTemplateID.fileExtendLibrary);
    createStandardFile(ctx, generator.pathExtendApplication, AFUISourceTemplateID.fileExtendApplication);
    createStandardFile(ctx, generator.pathExtendApp, extendAppId);
    createStandardFile(ctx, generator.pathExtendTest, AFUISourceTemplateID.fileExtendTest);
    
    _createEnvironmentFile(ctx, "Debug");
    _createEnvironmentFile(ctx, "Prototype");
    _createEnvironmentFile(ctx, "Test");
    _createEnvironmentFile(ctx, "Production");
    createStandardFile(ctx, generator.pathCreateDartParams, AFUISourceTemplateID.fileCreateDartParams);

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


  AFGeneratedFile _createAppCommand(AFCommandContext ctx, String libKind) {
    final generator = ctx.generator;
    final pathAppCommand = generator.pathAppCommand;
    final result = createStandardFile(ctx, pathAppCommand, AFUISourceTemplateID.fileAppcodeAFib);
    result.replaceText(ctx, AFUISourceTemplateID.textLibKind, libKind);
    return result;
  }



  AFGeneratedFile _createEnvironmentFile(AFCommandContext ctx, String suffix) {
    final result = createStandardFile(ctx, ctx.generator.pathEnvironment(suffix), AFUISourceTemplateID.fileEnvironment);
    result.replaceText(ctx, AFUISourceTemplateID.textEnvironmentName, suffix);
    return result;
  }

  void _createStandardFolders(AFCommandContext ctx, { required bool isApp }) {
    final generator = ctx.generator;
    generator.ensureFolderExists(AFCodeGenerator.commandPath);

    generator.ensureFolderExists(AFCodeGenerator.bottomSheetsPath);
    generator.ensureFolderExists(AFCodeGenerator.drawersPath);
    generator.ensureFolderExists(AFCodeGenerator.dialogsPath);
    generator.ensureFolderExists(AFCodeGenerator.widgetsPath);
    
    generator.ensureFolderExists(AFCodeGenerator.modelsPath);
    generator.ensureFolderExists(AFCodeGenerator.rootsPath);
    generator.ensureFolderExists(AFCodeGenerator.stateViewsPath);

    generator.ensureFolderExists(AFCodeGenerator.queryPath);
    
    if(isApp) {
      generator.ensureFolderExists(AFCodeGenerator.lpisOverridePath);
      generator.ensureFolderExists(AFCodeGenerator.overrideThemesPath);
    }

    generator.ensureFolderExists(AFCodeGenerator.prototypesPath);
    generator.ensureFolderExists(AFCodeGenerator.stateTestsPath);
    generator.ensureFolderExists(AFCodeGenerator.unitTestsPath);
    generator.ensureFolderExists(AFCodeGenerator.wireframesPath);

  }

  void _createStandardLibraryFolders(AFCommandContext ctx) {
    final generator = ctx.generator;
    generator.ensureFolderExists(AFCodeGenerator.lpisOverridePath);

  }
  
}
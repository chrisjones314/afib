
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_state_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_define_ui_functions.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_install_tests.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_ui_functions.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_screen_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_demo_screen_spi_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_empty_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_fundamental_theme_init.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_fundamental_theme_init_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_include_install_tests.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_prototype_environmentcontent.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_with_spi_no_back.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// Parent for commands executed through the afib command line app.
class AFCreateAppCommand extends AFCommand { 
  static const kindApp = "app";
  static const kindUILibrary = "ui_library";
  static const kindStateLibrary = "state_library";

  final String name = "create";
  final String description = "Install afib framework support into an existing flutter app project";

  String get usage {
    return '''
$usageHeader
  afib_bootstrap.dart create [$kindApp|$kindUILibrary|$kindStateLibrary] yourpackagename YPC

$descriptionHeader
  $description

$optionsHeader
  $kindApp - Install to create a full app
  $kindUILibrary - Install a UI library which exports screens, state, and queries for use in apps
  $kindStateLibrary - Install a state only library which can provide commands, state, lpis, but no UI 
  
  yourpackage - the full identifier for your package, all lowercase.   This is the value from your pubspec.yaml's
    name field, which should be in the folder you are running this command from. 
  YPC - a lowercase 2-5 digit the code/prefix for your app, all uppercase.  For example, for the AFib Signin library this is afsi, in the app 'Dinner Familias this is 'df' (
    note that you should not prefix yours with 'af')
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
    verifyOneOf(kind, [kindApp, kindUILibrary, kindStateLibrary]);

    final isApp = kind == kindApp;
    var libKind = "App";
    if(kind == kindUILibrary || kind == kindStateLibrary) {
      libKind = "Library";
    } 
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

    _createStandardFolders(ctx, kind: kind);
    if(!isApp) {
      _createStandardLibraryFolders(ctx);
      _createLibExportsFiles(ctx, kind);
    }
    _createAppCommand(ctx, libKind);
    createStandardFile(ctx, generator.pathAppId, AFUISourceTemplateID.fileAppcodeID);
    final fundamentalInit = isApp ? DeclareFundamentalThemeInitT() : DeclareFundamentalThemeInitUILibraryT();
    _createInitializationFiles(ctx, libKind, 
      isApp: isApp,
      kind: kind,
      defineFundamentalImpl: fundamentalInit);
    _createQueryFiles(ctx);
    _createStateFiles(ctx, kind);
    if(kind != kindStateLibrary) {
      _createTestFiles(ctx, libKind);
    }
    if(kind != kindStateLibrary) {
      final mainTemplateId = isApp ? AFUISourceTemplateID.fileMain : AFUISourceTemplateID.fileMainUILibrary;
      _createMainFiles(ctx, mainTemplateId);

      _createUIFiles(ctx, packageName, libKind, );
    }

    if(!isApp) {
      _createInstallFiles(ctx, kind);
    }
    

    generator.finalizeAndWriteFiles(ctx);
  }

  void _createInstallFiles(AFCommandContext ctx, String kind) {
    final generator = ctx.generator;
    final args = {
      AFCommand.argPrivate: false
    };

    // create the file and add it to the command exports.
    final fileInstallCommand = createStandardFile(ctx, generator.pathInstallCommand, AFUISourceTemplateID.fileInstallCommand);    
    generator.addExportsForFiles(ctx, args, [fileInstallCommand], toPath: generator.pathCommandExportsFile);

    // create the file and add it to the ui exports
    final fileInstallUI = createStandardFile(ctx, generator.pathInstall, AFUISourceTemplateID.fileInstallCore);
    final includeUI = kind != kindStateLibrary;
    final templateInclude = includeUI ? DeclareIncludeInstallTestsT() : DeclareEmptyStatementT();
    final templateCall = includeUI ? DeclareCallInstallTestsT() : DeclareEmptyStatementT();
    final includeBuffer = templateInclude.toBuffer();
    final appSuffix = kind == kindApp ? "app" : "library";
    final importCore = "import 'package:[!af_package_path]/initialization/install/install_core_$appSuffix.dart';";
    includeBuffer.addLinesAtEnd(ctx, [importCore]);

    fileInstallUI.replaceTextLines(ctx, AFUISourceTemplateID.stmtIncludeInstallTest, includeBuffer.lines);
    fileInstallUI.replaceTemplate(ctx, AFUISourceTemplateID.stmtCallInstallTest, templateCall);
    
    fileInstallUI.addImports(ctx, [importCore]);
    
    generator.addExportsForFiles(ctx, args, [fileInstallUI]);

  }

  void _createUIFiles(AFCommandContext ctx, String packageName, String libKind) {
    final generator = ctx.generator;
    createStandardFile(ctx, generator.pathConnectedBaseFile, AFUISourceTemplateID.fileConnectedBase);

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

  void _createLibExportsFiles(AFCommandContext ctx, String kind) {
    final generator = ctx.generator;
    createStandardFile(ctx, generator.pathFlutterExportsFile, AFUISourceTemplateID.fileLibExports);
    createStandardFile(ctx, generator.pathCommandExportsFile, AFUISourceTemplateID.fileLibExports);
  }

  void _createStateFiles(AFCommandContext ctx, String kind) {
    final generator = ctx.generator;

    createStandardFile(ctx, generator.pathStateModelAccess, AFUISourceTemplateID.fileStateModelAccess);
    createStandardFile(ctx, generator.pathAppState, AFUISourceTemplateID.fileState);

    final args = { 
      AFCommand.argPrivate: false,
      AFGenerateUISubcommand.argTheme: ctx.generator.nameDefaultTheme
    };
    
    if(kind != kindStateLibrary) {
      AFGenerateStateSubcommand.generateStateStatic(ctx, ctx.generator.nameDefaultStateView, args);
    }
  }

  void _createQueryFiles(AFCommandContext ctx) {
    final generator = ctx.generator;
    final createQueryArgs = {
      AFGenerateQuerySubcommand.argResultModelType: "AFUnused",
      AFGenerateQuerySubcommand.argRootStateType: generator.nameRootState,
    };

    AFGenerateQuerySubcommand.createQuery(
      ctx: ctx,
      querySuffix: AFGenerateQuerySubcommand.suffixQuery,
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
    final isApp = libKind == "App" ;
    final appParam = isApp ? "installCoreApp: installCoreApp" : "installCoreLibrary: installCoreLibrary,";
    if(isApp) {
      generator.addImport(ctx, 
        importPath: generator.importStatementPath(generator.pathInstallCoreApp), 
        to: fileMain, 
      );
    }

    fileMain.replaceText(ctx, AFUISourceTemplateID.textInstallAppParam, appParam);

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
    final mainFile = createStandardFile(ctx, generator.pathMain, mainTemplate);
    createStandardFile(ctx, generator.pathApp, AFUISourceTemplateID.fileApp);
    generator.addImport(ctx, 
      importPath: generator.importStatementPath(generator.pathInstallLibraryCore), 
      to: mainFile
    );
  }

  void _createInitializationFiles(AFCommandContext ctx, String libKind, { 
    required bool isApp,
    required String kind,
    required AFSourceTemplate defineFundamentalImpl,
  }) {
    final includeUI = kind != kindStateLibrary;


    final generator = ctx.generator;
    final fileDefineCore = createStandardFile(ctx, generator.pathDefineCore, AFUISourceTemplateID.fileDefineUI);
    final declareUIFn = includeUI ? DeclareUIFunctionsT() : DeclareEmptyStatementT();
    final callUIFn = includeUI ? CallUIFunctionsT() : DeclareEmptyStatementT();
    fileDefineCore.replaceTemplate(ctx, AFUISourceTemplateID.stmtDeclareUIFunctions, declareUIFn);
    fileDefineCore.replaceTemplate(ctx, AFUISourceTemplateID.stmtCallUIFunctions, callUIFn);
    fileDefineCore.replaceText(ctx, AFUISourceTemplateID.textLibKind, libKind);

    final imports = AFCodeBuffer.empty();

    if(includeUI) {
      imports.addLinesAtEnd(ctx, [
        "import 'package:afib/afib_flutter.dart",
        "import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';",
        "import 'package:[!af_package_path]/ui/screens/startup_screen.dart';"
      ]);
    }

    imports.addLinesAtEnd(ctx, [
      "import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';"
    ]);
    fileDefineCore.addImports(ctx, imports.lines);


    final defineFundImpl = defineFundamentalImpl.toBuffer();
    defineFundImpl.executeStandardReplacements(ctx);
    fileDefineCore.replaceTextLines(ctx, AFUISourceTemplateID.textFundamentalThemeInit, defineFundImpl.lines);

    createStandardFile(ctx, generator.pathInstallBase, AFUISourceTemplateID.fileExtendBase);
    createStandardFile(ctx, generator.pathInstallLibraryBase, AFUISourceTemplateID.fileExtendBaseLibrary);
    final fileExtendCommand = createStandardFile(ctx, generator.pathExtendCommand, AFUISourceTemplateID.fileExtendCommand);
    fileExtendCommand.replaceText(ctx, AFUISourceTemplateID.textLibKind, libKind);

    var extendAppId = AFUISourceTemplateID.fileExtendApp;
    if(kind == kindUILibrary) {
      extendAppId = AFUISourceTemplateID.fileExtendAppUILibrary;
    } else if(kind == kindStateLibrary) {
      extendAppId = AFUISourceTemplateID.fileExtendAppStateLibrary;
    }
    final pathAppCore = isApp ? generator.pathInstallCoreApp : generator.pathInstallLibraryCore;
    createStandardFile(ctx, generator.pathInstallLibraryCommand, AFUISourceTemplateID.fileExtendCommandLibrary);
    createStandardFile(ctx, generator.pathExtendApplication, AFUISourceTemplateID.fileExtendApplication);
    if(isApp) {
      createStandardFile(ctx, generator.pathInstallLibraryCore, AFUISourceTemplateID.fileExtendCoreLibraryApp);
    }
    if(!includeUI) {
      createStandardFile(ctx, generator.pathInstallLibraryCore, AFUISourceTemplateID.fileExtendLibrary);
    }
    createStandardFile(ctx, pathAppCore, extendAppId);
    if(includeUI) {
      createStandardFile(ctx, generator.pathInstallTest, AFUISourceTemplateID.fileExtendTest);
    }
    
    _createEnvironmentFile(ctx, "Debug", null);
    _createEnvironmentFile(ctx, "Prototype", DeclarePrototypeEnvironmentContentT());
    _createEnvironmentFile(ctx, "Test", null);
    _createEnvironmentFile(ctx, "Production", null);
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



  AFGeneratedFile _createEnvironmentFile(AFCommandContext ctx, String suffix, AFSourceTemplate? content) {
    final result = createStandardFile(ctx, ctx.generator.pathEnvironment(suffix), AFUISourceTemplateID.fileEnvironment);
    result.replaceText(ctx, AFUISourceTemplateID.textEnvironmentName, suffix);
    result.replaceTemplate(ctx, AFUISourceTemplateID.textContent, content ?? DeclareEmptyStatementT());
    return result;
  }

  void _createStandardFolders(AFCommandContext ctx, { required String kind }) {
    final generator = ctx.generator;
    final isStateLib = kind == kindStateLibrary;

    generator.ensureFolderExists(AFCodeGenerator.commandPath);

    if(!isStateLib) {
      generator.ensureFolderExists(AFCodeGenerator.bottomSheetsPath);
      generator.ensureFolderExists(AFCodeGenerator.drawersPath);
      generator.ensureFolderExists(AFCodeGenerator.dialogsPath);
      generator.ensureFolderExists(AFCodeGenerator.widgetsPath);
    }
    
    generator.ensureFolderExists(AFCodeGenerator.modelsPath);
    generator.ensureFolderExists(AFCodeGenerator.rootsPath);
    generator.ensureFolderExists(AFCodeGenerator.stateViewsPath);

    generator.ensureFolderExists(AFCodeGenerator.queryPath);
    
    generator.ensureFolderExists(AFCodeGenerator.lpisOverridePath);
    generator.ensureFolderExists(AFCodeGenerator.overrideThemesPath);

    if(!isStateLib) {
      generator.ensureFolderExists(AFCodeGenerator.prototypesPath);
      generator.ensureFolderExists(AFCodeGenerator.stateTestsPath);
      generator.ensureFolderExists(AFCodeGenerator.unitTestsPath);
      generator.ensureFolderExists(AFCodeGenerator.wireframesPath);
    }
  }

  void _createStandardLibraryFolders(AFCommandContext ctx) {
    final generator = ctx.generator;
    generator.ensureFolderExists(AFCodeGenerator.lpisOverridePath);

  }
  
}

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/core/app.t.dart';
import 'package:afib/src/dart/command/templates/core/app_state.t.dart';
import 'package:afib/src/dart/command/templates/core/command_afib.t.dart';
import 'package:afib/src/dart/command/templates/core/configure_application.t.dart';
import 'package:afib/src/dart/command/templates/core/configure_environment.t.dart';
import 'package:afib/src/dart/command/templates/core/connected_base.t.dart';
import 'package:afib/src/dart/command/templates/core/create_dart_params.t.dart';
import 'package:afib/src/dart/command/templates/core/define_core.t.dart';
import 'package:afib/src/dart/command/templates/core/define_tests.t.dart';
import 'package:afib/src/dart/command/templates/core/id.t.dart';
import 'package:afib/src/dart/command/templates/core/install_base.t.dart';
import 'package:afib/src/dart/command/templates/core/install_command.t.dart';
import 'package:afib/src/dart/command/templates/core/install_core.t.dart';
import 'package:afib/src/dart/command/templates/core/install_core_app.t.dart';
import 'package:afib/src/dart/command/templates/core/install_core_library.t.dart';
import 'package:afib/src/dart/command/templates/core/install_core_library_app.t.dart';
import 'package:afib/src/dart/command/templates/core/install_library_base.t.dart';
import 'package:afib/src/dart/command/templates/core/install_library_command.t.dart';
import 'package:afib/src/dart/command/templates/core/install_test.t.dart';
import 'package:afib/src/dart/command/templates/core/library_exports.t.dart';
import 'package:afib/src/dart/command/templates/core/library_install_command.t.dart';
import 'package:afib/src/dart/command/templates/core/main.t.dart';
import 'package:afib/src/dart/command/templates/core/main_afib_test.t.dart';
import 'package:afib/src/dart/command/templates/core/main_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/core/state_model_access.t.dart';
import 'package:afib/src/dart/command/templates/core/state_test_shortcuts.t.dart';
import 'package:afib/src/dart/command/templates/core/test_data.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_fundamental_theme_init.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_fundamental_theme_init_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_install_tests.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_empty_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_include_install_tests.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_prototype_environmentcontent.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFCreateCommandContext {
  final AFCommandContext command;
  final String kind;
  final AFSourceTemplateInsertions insertions;

  AFCreateCommandContext({
    required this.command,
    required this.kind,
    required this.insertions,
  });
  
  factory AFCreateCommandContext.create({
    required AFCommandContext command,
    required String kind,
  }) {
     final coreInsertions = AFSourceTemplateInsertions.createCore(command);

      final insertions = coreInsertions.reviseAugment({
        AFSourceTemplate.insertLibKindInsertion: kind == AFCreateAppCommand.kindApp ? "App" : "Library"
      });

     return AFCreateCommandContext(command: command, kind: kind, insertions: insertions);
  }

  bool get includeUI => !isStateLibrary;
  bool get isApp => kind == AFCreateAppCommand.kindApp;
  bool get isUILibrary => kind == AFCreateAppCommand.kindUILibrary;
  bool get isStateLibrary => kind == AFCreateAppCommand.kindStateLibrary;
  bool get isLibrary => !isApp;
  String get kindSuffix {
    return isLibrary ? "Library" : "App";
  }

  void executeSubCommand(String cmd) {
    final revisedCommand = command.reviseWithArguments(
      insertions: insertions, 
      arguments: AFArgs.createFromString(cmd)
    );

    command.definitions.execute(revisedCommand);
  }

  AFCodeGenerator get generator => command.generator;
  AFCommandOutput get output => command.output;

  AFGeneratedFile createFile(
    List<String> projectPath,
    AFFileSourceTemplate template, { Map<AFSourceTemplateInsertion, Object>? insertions })  {
    var fullInsert = this.insertions;
    if(insertions != null) {
      fullInsert = fullInsert.reviseAugment(insertions);
    }
    return generator.createFile(command, projectPath, template, insertions: fullInsert);
  }
}

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
  ${AFGenerateSubcommand.argExportTemplatesHelpStatic}
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

    AFibD.config.setIsLibraryCommand(isLib: kind != kindApp);
    final packageName = args[2];
    final packageCode = args[3];

    verifyAllLowercase(packageCode);
    verifyAllLowercase(packageName);
    AFibD.registerGlobals();

    AFibD.config.putInternal(AFConfigEntries.appNamespace, packageCode);
    AFibD.config.putInternal(AFConfigEntries.packageName, packageName);
    AFibD.config.putInternal(AFConfigEntries.environment, AFEnvironment.debug);

    final context = AFCreateCommandContext.create(
      command: ctx, 
      kind: kind
    );


    final generator = ctx.generator;
    _verifyPubspec(ctx, packageName);

    _createStandardFolders(context);
    if(!context.isLibrary) {
      _createStandardLibraryFolders(ctx);
      _createLibExportsFiles(context);
    }
    _createAppCommand(context);
    context.createFile(generator.pathAppId, IDT());

    _createInitializationFiles(context);

    _createQueryFiles(context);
    _createStateFiles(context);
    if(!context.isStateLibrary) {
      _createTestFiles(context);
    }


    if(!context.isStateLibrary) {
      _createMainFiles(context);
      _createUIFiles(context);
    }

    if(!context.isApp) {
      _createInstallFiles(context, kind);
    }

    generator.finalizeAndWriteFiles(ctx);
  }

  void _createInstallFiles(AFCreateCommandContext context, String kind) {
    final generator = context.generator;
    final args = {
      AFCommand.argPrivate: false
    };

    // create the file and add it to the command exports.
    final fileInstallCommand = context.createFile(generator.pathInstallCommand, LibraryInstallCommandT());    
    generator.addExportsForFiles(context.command, args, [fileInstallCommand], toPath: generator.pathCommandExportsFile);

    // create the file and add it to the ui exports
    final fileInstallUI = context.createFile(generator.pathInstall, LibraryInstallCoreT());
    final includeUI = kind != kindStateLibrary;
    final templateInclude = includeUI ? DeclareIncludeInstallTestsT() : AFSourceTemplate.empty;
    final templateCall = includeUI ? DeclareCallInstallTestsT() : AFSourceTemplate.empty;
    final cmdContext = context.command;
    final includeBuffer = templateInclude.toBuffer(cmdContext);
    final appSuffix = kind == kindApp ? "app" : "library";
    final importCore = "import 'package:[!af_package_path]/initialization/install/install_core_$appSuffix.dart';";
    includeBuffer.addLinesAtEnd(cmdContext, [importCore]);

    fileInstallUI.replaceTextLines(cmdContext, AFUISourceTemplateID.stmtIncludeInstallTest, includeBuffer.lines);
    fileInstallUI.replaceTemplate(cmdContext, AFUISourceTemplateID.stmtCallInstallTest, templateCall);
    
    fileInstallUI.addImports(cmdContext, [importCore]);
    
    generator.addExportsForFiles(cmdContext, args, [fileInstallUI]);

  }

  void _createUIFiles(AFCreateCommandContext context) {
    final generator = context.generator;
    context.createFile(generator.pathConnectedBaseFile, ConnectedBaseT());

    context.executeSubCommand("generate ui ${generator.appNamespaceUpper}DefaultTheme --${AFGenerateUISubcommand.argParentTheme} ${generator.nameDefaultParentTheme} --${AFGenerateUISubcommand.argParentThemeID} ${generator.nameDefaultParentThemeID}");
    context.executeSubCommand("generate ui ${AFGenerateUISubcommand.nameStartupScreen}");
  }

  void _createLibExportsFiles(AFCreateCommandContext context) {
    final generator = context.generator;
    context.createFile(generator.pathFlutterExportsFile, LibraryExportsT());
    context.createFile(generator.pathCommandExportsFile, LibraryExportsT());
  }

  void _createStateFiles(AFCreateCommandContext context) {
    final generator = context.generator;

    context.createFile(generator.pathStateModelAccess, StateModelAccessT());
    context.createFile(generator.pathAppState, AppStateT());
    
    if(!context.isStateLibrary) {
      context.executeSubCommand("generate state ${generator.nameDefaultStateView} --${AFGenerateUISubcommand.argTheme} ${generator.nameDefaultTheme}");
    }
  }

  void _createQueryFiles(AFCreateCommandContext context) {
    context.executeSubCommand("generate query ${context.generator.nameStartupQuery} --${AFGenerateQuerySubcommand.argResultModelType} AFUnused");
  }

  void _createTestFiles(AFCreateCommandContext context) {
    final generator = context.generator;

    generator.renameExistingFileToOld(context.command, generator.pathOriginalWidgetTest);
    final appParam = context.isApp ? "installCoreApp: installCoreApp" : "installCoreLibrary: installCoreLibrary,";
    final fileMain = context.createFile(generator.pathMainAFibTest, MainAFibTestT(), insertions: {
      MainAFibTestT.insertInstallAppParam: appParam,

    });
    if(context.isApp) {
      generator.addImport(context.command, 
        importPath: generator.importStatementPath(generator.pathInstallCoreApp), 
        to: fileMain, 
      );
    }

    context.createFile(generator.pathTestData, TestDataT());
    context.createFile(generator.pathStateTestShortcutsFile, StateTestShortcutsT());
    
    _createTestDefinitionFile(context, "Wireframe");
    _createTestDefinitionFile(context, "UIPrototype", filename: "ui_prototype");
    _createTestDefinitionFile(context, "StateTest");
    _createTestDefinitionFile(context, "UnitTest");
  }

  AFGeneratedFile _createTestDefinitionFile(AFCreateCommandContext context, String kind, { String? filename }) {
    final generator = context.generator;
    return context.createFile(generator.pathTestDefinitions(filename ?? AFCodeGenerator.convertMixedToSnake(kind)), DefineTestsT(), insertions: {
      DefineTestsT.insertTestKind: kind
    });
  }

  void _createMainFiles(AFCreateCommandContext context) {

    final generator = context.generator;
    generator.renameExistingFileToOld(context.command, generator.pathMain);
    final mainTemplate = context.isApp ? MainT() : MainUILibraryT();

    final mainFile = context.createFile(generator.pathMain, mainTemplate);
    context.createFile(generator.pathApp, AppT());
    generator.addImport(context.command, 
      importPath: generator.importStatementPath(generator.pathInstallLibraryCore), 
      to: mainFile
    );
  }

  void _createInitializationFiles(AFCreateCommandContext context) {

    final includeUI = context.includeUI;

    final generator = context.generator;
    final declareUIFn = includeUI ? DefineCoreUIFunctionsT() : AFSourceTemplate.empty;
    final callUIFn = includeUI ? DefineCoreCallUIFunctionsT() : AFSourceTemplate.empty;
    final defineFundamentalImpl = context.isApp ? SnippetFundamentalThemeInitT() : SnippetFundamentalThemeInitUILibraryT();
    final fileDefineCore = context.createFile(generator.pathDefineCore, DefineCoreT(), insertions: {
      DefineCoreT.insertCallUIFunctions: callUIFn,
      DefineCoreT.insertDeclareUIFunctions: declareUIFn,
      DefineCoreUIFunctionsT.insertFundamentalThemeInitCall: defineFundamentalImpl,
    });

    final imports = AFCodeBuffer.empty();

    if(includeUI) {
      imports.addLinesAtEnd(context.command, [
        "import 'package:afib/afib_flutter.dart",
        "import 'package:${AFSourceTemplate.insertPackagePathInsertion}/${AFSourceTemplate.insertAppNamespaceInsertion}_id.dart';",
        "import 'package:${AFSourceTemplate.insertPackagePathInsertion}/ui/screens/startup_screen.dart';"
      ]);
    }

    imports.addLinesAtEnd(context.command, [
      "import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/${AFSourceTemplate.insertAppNamespaceInsertion}_state.dart';"
    ]);
    fileDefineCore.addImports(context.command, imports.lines);

    context.createFile(generator.pathInstallBase, InstallBaseT());
    context.createFile(generator.pathInstallLibraryBase, InstallLibraryBaseT());
    context.createFile(generator.pathExtendCommand, InstallCommandT());

    context.createFile(generator.pathInstallLibraryCommand, InstallLibraryCommandT());
    context.createFile(generator.pathExtendApplication, ConfigureApplicationT());
    if(context.isApp) {
      context.createFile(generator.pathInstallLibraryCore, InstallCoreLibraryAppT());
    }
    if(!includeUI) {
      context.createFile(generator.pathInstallLibraryCore, InstallStateLibraryT());
    }

    AFFileSourceTemplate extendApp = InstallCoreAppT();
    if(context.isUILibrary) {
      extendApp = InstallUILibraryT();
    } else if(context.isStateLibrary) {
      extendApp = InstallStateLibraryT();
    }
    final pathAppCore = context.isApp ? generator.pathInstallCoreApp : generator.pathInstallLibraryCore;
    context.createFile(pathAppCore, extendApp);

    if(includeUI) {
      context.createFile(generator.pathInstallTest, InstallTestT());
    }

    _createEnvironmentFile(context, "Debug", null);
    _createEnvironmentFile(context, "Prototype", DeclarePrototypeEnvironmentContentT());
    _createEnvironmentFile(context, "Test", null);
    _createEnvironmentFile(context, "Production", null);
    context.createFile(generator.pathCreateDartParams, CreateDartParamsT());

    AFConfigCommand.updateConfig(context.command, AFibD.config, AFibD.configEntries, context.command.arguments);
    AFConfigCommand.writeUpdatedConfig(context.command);
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


  AFGeneratedFile _createAppCommand(AFCreateCommandContext context) {
    final generator = context.generator;
    final pathAppCommand = generator.pathAppCommand;
    
    final result = context.createFile(pathAppCommand, CommandAFibT());
    return result;
  }



  AFGeneratedFile _createEnvironmentFile(AFCreateCommandContext context, String suffix, AFSourceTemplate? body) {
    final result = context.createFile(context.generator.pathEnvironment(suffix), ConfigureEnvironmentT(), insertions: {
      ConfigureEnvironmentT.insertEnvironmentName: suffix,
      ConfigureEnvironmentT.insertConfigureBody: body ?? DeclareEmptyStatementT()
    });

    return result;
  }

  void _createStandardFolders(AFCreateCommandContext ctx) {
    final generator = ctx.generator;
    final isStateLib = ctx.isStateLibrary;

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
    generator.ensureFolderExists(AFCodeGenerator.querySimplePath);
    generator.ensureFolderExists(AFCodeGenerator.queryDeferredPath);
    generator.ensureFolderExists(AFCodeGenerator.queryListenerPath);
    generator.ensureFolderExists(AFCodeGenerator.queryIsolatePath);
    
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
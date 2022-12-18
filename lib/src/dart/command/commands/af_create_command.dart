
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/core/files/app.t.dart';
import 'package:afib/src/dart/command/templates/core/files/app_state.t.dart';
import 'package:afib/src/dart/command/templates/core/files/command_afib.t.dart';
import 'package:afib/src/dart/command/templates/core/files/configure_application.t.dart';
import 'package:afib/src/dart/command/templates/core/files/configure_environment.t.dart';
import 'package:afib/src/dart/command/templates/core/files/connected_base.t.dart';
import 'package:afib/src/dart/command/templates/core/files/create_dart_params.t.dart';
import 'package:afib/src/dart/command/templates/core/files/define_core.t.dart';
import 'package:afib/src/dart/command/templates/core/files/define_tests.t.dart';
import 'package:afib/src/dart/command/templates/core/files/id.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_base.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_command.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_core.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_core_app.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_core_library.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_core_library_app.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_library_base.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_library_command.t.dart';
import 'package:afib/src/dart/command/templates/core/files/install_test.t.dart';
import 'package:afib/src/dart/command/templates/core/files/library_exports.t.dart';
import 'package:afib/src/dart/command/templates/core/files/library_install_command.t.dart';
import 'package:afib/src/dart/command/templates/core/files/main.t.dart';
import 'package:afib/src/dart/command/templates/core/files/main_afib_test.t.dart';
import 'package:afib/src/dart/command/templates/core/files/main_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/core/files/state_model_access.t.dart';
import 'package:afib/src/dart/command/templates/core/files/state_test_shortcuts.t.dart';
import 'package:afib/src/dart/command/templates/core/files/test_data.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_install_tests.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_empty_statement.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_fundamental_theme_init.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_fundamental_theme_init_ui_library.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_include_install_tests.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_prototype_environment_impl.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class AFCreateCommandContext {
  final AFCommandContext command;
  final String kind;
  final AFCodeBuffer projectStyle;
  final AFSourceTemplateInsertions insertions;
  

  AFCreateCommandContext({
    required this.command,
    required this.kind,
    required this.insertions,
    required this.projectStyle,
  });
  
  factory AFCreateCommandContext.create({
    required AFCommandContext command,
    required String kind,
    required String projectStyle,
  }) {
      final packagePath = command.generator.packagePath(AFibD.config.packageName);
     var coreInsertions = AFSourceTemplateInsertions.createCore(packagePath: packagePath);
     coreInsertions = coreInsertions.reviseAugment(command.coreInsertions.insertions);

      final insertions = coreInsertions.reviseAugment({
        AFSourceTemplate.insertLibKindInsertion: kind == AFCreateAppCommand.kindApp ? "App" : "Library"
      });

      final stylePath = AFProjectPaths.pathProjectStyles.toList();
      stylePath.add(projectStyle);

      command.setCoreInsertions(coreInsertions, packagePath: packagePath);

     final fileProjectStyle = command.readProjectStyle(stylePath, insertions: insertions.insertions);
     return AFCreateCommandContext(command: command, kind: kind, insertions: insertions, projectStyle: fileProjectStyle.buffer);
  }

  List<String> get projectStyleLines {

    final rawLines = projectStyle.lines;
    return AFCommandContext.consolidateProjectStyleLines(rawLines);
  }


  bool get includeUI => !isStateLibrary;
  bool get isApp => kind == AFCreateAppCommand.kindApp;
  bool get isUILibrary => kind == AFCreateAppCommand.kindUILibrary;
  bool get isStateLibrary => kind == AFCreateAppCommand.kindStateLibrary;
  bool get isLibrary => !isApp;
  String get kindSuffix {
    return isLibrary ? "Library" : "App";
  }

  Future<void> executeSubCommand(String cmd) async {
    await command.executeSubCommand(cmd, insertions);
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
  static const argProjectStyle = "project-style";
  static const projectStyleMinimal = "minimal";
  static const integrateSuffix = "-integrate";
  static const projectStyleEvalDemo = "eval-demo";
  static const projectStyleSignin = "starter-signin";
  static const projectStyleSigninIntegrate = "starter-signin$integrateSuffix";
  static const projectStyleSigninFirebase = "starter-signin-firebase";

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
  $argProjectStyle - a string specifying the project style to use, currently:
    $projectStyleMinimal - minimal project style
    $projectStyleEvalDemo - a simple example demonstrating many of AFib's core features and referenced in the evaluation video and documentation.
    $projectStyleSignin - a simple starter project how to use AFib signin, if you are not using firebase for signin
    $projectStyleSigninFirebase - a starter project showing how to use AFib signin with Firebase
    or, you can define your own project styles.

  ${AFGenerateSubcommand.argExportTemplatesHelpStatic}
''';
  }


  AFCreateAppCommand();

  Future<void> run(AFCommandContext ctx) async {
    // override this to avoid 'error not in root of project'
    await execute(ctx);
  }

  Future<void> execute(AFCommandContext ctx) async {
    final args = ctx.parseArguments(
      command: this,
      unnamedCount: 3,
      named: {
      argProjectStyle: "",
    });
    final kind = args.accessUnnamedFirst;
    verifyOneOf(kind, [kindApp, kindUILibrary, kindStateLibrary]);

    AFibD.config.setIsLibraryCommand(isLib: kind != kindApp);
    final packageName = args.accessUnnamedSecond;
    final packageCode = args.accessUnnamedThird;

    final projectStyle = args.accessNamed(argProjectStyle);
    ctx.setProjectStyle(projectStyle);

    if(projectStyle == null || projectStyle.isEmpty) {
      throwUsageError("You must specify --$argProjectStyle");
    }

    verifyAllLowercase(packageCode);
    verifyAllLowercase(packageName);
    AFibD.registerGlobals();

    AFibD.config.putInternal(AFConfigEntries.appNamespace, packageCode);
    AFibD.config.putInternal(AFConfigEntries.packageName, packageName);
    AFibD.config.putInternal(AFConfigEntries.environment, AFEnvironment.debug);

    final context = AFCreateCommandContext.create(
      command: ctx, 
      kind: kind,
      projectStyle: projectStyle,
    );

    context.output.writeTwoColumns(col1: "creating ", col2: "project-style=$projectStyle");

    final generator = ctx.generator;
    final pubspec = ctx.loadPubspec(packageName: packageName);

    _createStandardFolders(context);
    if(!context.isLibrary) {
      _createStandardLibraryFolders(ctx);
      _createLibExportsFiles(context);
    }
    _createAppCommand(context);
    context.createFile(generator.pathAppId, IDT());

    _createInitializationFiles(context);

    await _createQueryFiles(context);
    await _createStateFiles(context);
    if(!context.isStateLibrary) {
      _createTestFiles(context);
    }

    if(!context.isStateLibrary) {
      _createMainFiles(context);
      await _createUIFiles(context);
    }

    if(!context.isApp) {
      _createInstallFiles(context, kind, args);
    }

    await _executeProjectStyle(context);

    generator.finalizeAndWriteFiles(ctx);

    await _executeProjectStyleEcho(context);
  }

  Future<void> _executeProjectStyle(AFCreateCommandContext context) async {
    final lines = context.projectStyleLines;
    for(final line in lines) {
      if(!line.startsWith("echo ")) {
        context.output.writeTwoColumns(col1: "execute ", col2: "$line");
        await context.executeSubCommand(line);
      }
    }
  }

  Future<void> _executeProjectStyleEcho(AFCreateCommandContext context) async {
    final lines = context.projectStyleLines;
    for(final line in lines) {
      if(line.startsWith("echo ")) {
        await context.executeSubCommand(line);
      }
    }
  }

  void _createInstallFiles(AFCreateCommandContext context, String kind, AFCommandArgumentsParsed args) {
    final generator = context.generator;

    // create the file and add it to the command exports.
    final fileInstallCommand = context.createFile(generator.pathInstallCommand, LibraryInstallCommandT());    
    generator.addExportsForFiles(context.command, args, [fileInstallCommand], toPath: generator.pathCommandExportsFile);

    // create the file and add it to the ui exports
    final includeUI = kind != kindStateLibrary;
    final templateInclude = includeUI ? SnippetImportInstallTestsT() : AFSourceTemplate.empty;
    final templateCall = includeUI ? SnippetCallInstallTestT() : AFSourceTemplate.empty;
    final cmdContext = context.command;
    final includeBuffer = templateInclude.toBuffer(cmdContext);
    final appSuffix = kind == kindApp ? "app" : "library";
    final importCore = "import 'package:${AFSourceTemplate.insertPackagePathInsertion}/initialization/install/install_core_$appSuffix.dart';";

    includeBuffer.addLinesAtEnd(cmdContext, [importCore]);

    final fileInstallUI = context.createFile(generator.pathInstall, LibraryInstallCoreT(), insertions: {
      LibraryInstallCoreT.insertIncludeInstallTests: includeBuffer.lines,
      LibraryInstallCoreT.insertCallInstallTests: templateCall,
    });
    
    fileInstallUI.importAll(cmdContext, [importCore]);
    
    generator.addExportsForFiles(cmdContext, args, [fileInstallUI]);

  }

  Future<void> _createUIFiles(AFCreateCommandContext context) async {
    final generator = context.generator;
    context.createFile(generator.pathConnectedBaseFile, ConnectedBaseT());

    await context.executeSubCommand("generate ui ${generator.appNamespaceUpper}DefaultTheme --${AFGenerateUISubcommand.argParentTheme} ${generator.nameDefaultParentTheme} --${AFGenerateUISubcommand.argParentThemeID} ${generator.nameDefaultParentThemeID}");
    await context.executeSubCommand("generate ui ${AFGenerateUISubcommand.nameStartupScreen}");
  }

  void _createLibExportsFiles(AFCreateCommandContext context) {
    final generator = context.generator;
    context.createFile(generator.pathFlutterExportsFile, LibraryExportsT());
    context.createFile(generator.pathCommandExportsFile, LibraryExportsT());
  }

  Future<void> _createStateFiles(AFCreateCommandContext context) async {
    final generator = context.generator;

    context.createFile(generator.pathStateModelAccess, StateModelAccessT());
    context.createFile(generator.pathAppState, AppStateT());
    
    if(!context.isStateLibrary) {
      await context.executeSubCommand("generate state ${generator.nameDefaultStateView} --${AFGenerateUISubcommand.argTheme} ${generator.nameDefaultTheme}");
    }
  }

  Future<void> _createQueryFiles(AFCreateCommandContext context) async {
    await context.executeSubCommand("generate query ${context.generator.nameStartupQuery} --${AFGenerateQuerySubcommand.argResultModelType} AFUnused");
  }

  void _createTestFiles(AFCreateCommandContext context) {
    final generator = context.generator;

    generator.renameExistingFileToOld(context.command, generator.pathOriginalWidgetTest);
    final appParam = context.isApp ? "installCoreApp: installCoreApp" : "installCoreLibrary: installCoreLibrary,";
    final fileMain = context.createFile(generator.pathMainAFibTest, MainAFibTestT(), insertions: {
      MainAFibTestT.insertInstallAppParam: appParam,

    });
    if(context.isApp) {
      fileMain.importProjectPathString(context.command, generator.importStatementPath(generator.pathInstallCoreApp));
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
    mainFile.importProjectPathString(context.command, generator.importStatementPath(generator.pathInstallLibraryCore));
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
    fileDefineCore.importAll(context.command, imports.lines);

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
    _createEnvironmentFile(context, "Prototype", SnippetPrototypeEnvironmentImplT());
    _createEnvironmentFile(context, "Test", null);
    _createEnvironmentFile(context, "Production", null);
    context.createFile(generator.pathCreateDartParams, CreateDartParamsT());

    AFConfigCommand.updateConfig(context.command, AFibD.config, AFibD.configEntries, context.command.arguments);
    AFConfigCommand.writeUpdatedConfig(context.command);
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
      ConfigureEnvironmentT.insertConfigureBody: body ?? SnippetEmptyStatementT()
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
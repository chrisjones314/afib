import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/screen.t.dart';
import 'package:afib/src/dart/command/templates/core/theme.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_standard_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/snippets/widget_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_bottom_sheet_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_define_screen_test.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_create_screen_prototype.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_create_widget_prototype.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_theme.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_dialog_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_drawer_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_launch_param_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_no_scaffold_build_with_spi.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_empty_screen_build_body_impl.t.dart';
import 'package:afib/src/dart/command/templates/snippets/snippet_screen_build_with_spi_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_impls_super.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_map_entry.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi_on_pressed_closed.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi_on_tap_close.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_startup_screen_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_test_screen_shortcut.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_test_widget_shortcut.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_impls_super.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_params_constructor.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

enum AFUIControlKind {
  screen,
  bottomSheet,
  drawer,
  dialog,
  widget,
}

class AFUIControlSettings {
  final AFUIControlKind kind;
  final String suffix;
  final List<String> path;
  final AFSourceTemplate implBuildWithSPI;
  final AFSourceTemplate implBuildBody;
  final AFSourceTemplate implsSPI;
  final AFSourceTemplate implsSuper;
  final AFSourceTemplate paramsConstructor;
  final AFSourceTemplate routeParamImpls;
  final AFSourceTemplate navigatePush;
  final AFSourceTemplate spi;
  final AFSourceTemplate stateTestShortcut;
  final AFSourceTemplate createPrototype;

  const AFUIControlSettings({
    required this.kind,
    required this.suffix,
    required this.path,
    required this.implBuildWithSPI,
    required this.implBuildBody,
    required this.implsSPI,
    required this.implsSuper,
    required this.paramsConstructor,
    required this.routeParamImpls,
    required this.navigatePush,
    required this.spi,
    required this.stateTestShortcut,
    required this.createPrototype,
  });

  bool matchesName(String uiName) {
    return uiName.endsWith(suffix);
  }

  List<String> get prototypesPath {
    final result = List<String>.from(AFCodeGenerator.prototypesPath);
    result.add(path.last);
    return result;
  }

  String toString() {
    return suffix;
  }
}

class AFGenerateUISubcommand extends AFGenerateSubcommand {
  static const nameStartupScreen = "StartupScreen";
  static const nameButtonIncrementRouteParam = "buttonIncrementRouteParam";
  static const nameTextCountRouteParam = "textCountRouteParam";
  static const argRouteParam = "routeParam";
  static const argStateView = "state-view";
  static const argTheme = "theme";
  static const argParentTheme = "parent-theme";
  static const argParentThemeID = "parent-theme-id";
  static const argParentPackageName = "parent-package-name";
  static const screenSuffix = "Screen";
  static const bottomSheetSuffix = "BottomSheet";
  static const drawerSuffix = "Drawer";
  static const dialogSuffix = "Dialog";
  static const widgetSuffix = "Widget";
  static final controlSettingsWidget = AFUIControlSettings(
      kind: AFUIControlKind.widget, 
      suffix: widgetSuffix, 
      path: AFCodeGenerator.widgetsPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareWidgetBuildBodyImplT(),
      implsSPI: AFSourceTemplate.empty,
      implsSuper: DeclareWidgetImplsSuperT(),
      paramsConstructor: DeclareWidgetParamsConstructorT(),
      routeParamImpls: DeclareWidgetRouteParamImplsT(),
      navigatePush: AFSourceTemplate.empty,
      spi: SnippetDeclareSPIT(),
      stateTestShortcut: DeclareStateTestWidgetShortcutT(),
      createPrototype: DeclareCreateWidgetPrototypeT(),
    );

  static final controlKinds = [
    AFUIControlSettings(
      kind: AFUIControlKind.screen, 
      suffix: screenSuffix, 
      path: AFCodeGenerator.screensPath,
      implBuildWithSPI: SnippetScreenBuildWithSPIImplT(),
      implBuildBody: SnippetMinimalScreenBuildBodyImplT(),
      implsSPI: AFSourceTemplate.empty,
      implsSuper: DeclareScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT(),
      navigatePush: SnippetNavigatePushT.noCreateParams(),
      spi: SnippetDeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT.noPushParams(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.bottomSheet, 
      suffix: bottomSheetSuffix, 
      path: AFCodeGenerator.bottomSheetsPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareBottomSheetBuildBodyImplT(),
      implsSPI: DeclareSPIOnPressedCloseImplT(),
      implsSuper: DeclareScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT(),
      navigatePush: SnippetNavigatePushT.noCreateParams(),
      spi: SnippetDeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT.noPushParams(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.drawer, 
      suffix: drawerSuffix, 
      path: AFCodeGenerator.drawersPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareDrawerBuildBodyImplT(),
      implsSPI: DeclareSPIOnTapCloseImplT(),
      implsSuper: DeclareLaunchParamImplT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT(),
      navigatePush: SnippetNavigatePushT.noCreateParams(),
      spi: SnippetDeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT.noPushParams(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.dialog, 
      suffix: dialogSuffix, 
      path: AFCodeGenerator.dialogsPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareDialogBuildBodyImplT(),
      implsSPI: DeclareSPIOnPressedCloseImplT(),
      implsSuper: DeclareScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT(),
      navigatePush: SnippetNavigatePushT.noCreateParams(),
      spi: SnippetDeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT.noPushParams(),
    ),
    controlSettingsWidget,
  ];

  AFGenerateUISubcommand();
  
  @override
  String get description => "Generate a screen";

  @override
  String get name => "ui";


  String get usage {
    return '''
$usageHeader
  $nameOfExecutable generate ui Your[${controlKinds.join('|')}]|YourTheme [any --options]

$descriptionHeader
  Create a new screen template under lib/ui/screens, adding an appropriate screen id and 
  test shortcut.

$optionsHeader
  YourScreen... - should end with one of the specified suffixes, e.g. $screenSuffix, $bottomSheetSuffix, etc.
  --$argStateView YourStateView - the state view to use, falls back to your default state view
  --$argTheme YourTheme - the theme to use, falls back to your default theme, NOT used when creating themes

  ${AFCommand.argPrivateOptionHelp}
  
''';
  }

  @override
  void execute(AFCommandContext context) {
    final unnamed = context.rawArgs;
    if(unnamed.isEmpty) {
      throwUsageError("You must specify at least the screen name.");
    }

    final uiName = unnamed[0];
    final generator = context.generator;
    final args = parseArguments(unnamed, defaults: {
      argStateView: generator.nameDefaultStateView,
      argTheme: generator.nameDefaultTheme,
      argParentTheme: generator.nameDefaultParentTheme,
      argParentThemeID: generator.nameDefaultParentThemeID
    });

    verifyMixedCase(uiName, "ui name");
    verifyNotOption(uiName);

    if(uiName.endsWith("Theme")) {
      createTheme(context, uiName, args.named);
    } else {
      createScreen(context, uiName, args.named);
    }

    // replace any default 
    generator.finalizeAndWriteFiles(context);

  }

  static AFGeneratedFile createTheme(AFCommandContext context, String uiName, Map<String, dynamic> args, {
    String? fullId,
    AFLibraryID? fromLib,
  }) {
    final generator = context.generator;
    final parentTheme = args[argParentTheme];
    final String parentThemeID = args[argParentThemeID];
    final isCustomParent = parentTheme != generator.nameDefaultParentTheme;

    final isOverride = fullId != null;
    final pathTheme = generator.pathTheme(uiName, isCustomParent: isCustomParent);
    if(pathTheme == null) {
      throw AFException("Could not generate theme path");
    }

    if(isCustomParent) {
      if(parentThemeID == generator.nameDefaultParentThemeID) {
        throw AFCommandError(error: "You specified $parentTheme as the parent theme, you must also specify its full theme id using --$argParentThemeID");
      }
    } 

    // create the theme file itself.
    final fileTheme = context.createFile(pathTheme, ThemeT(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: uiName,
      AFSourceTemplate.insertMainParentTypeInsertion: parentTheme ?? "AFFunctionalTheme"
    });
    final imports = <String>[];
    if(isCustomParent && fromLib != null) {
      var parentThemePackage = fromLib.name;
      final import = ImportFromPackage().toBuffer(context);
      import.replaceText(context, AFUISourceTemplateID.textPackageName, parentThemePackage);
      import.replaceText(context, AFUISourceTemplateID.textPackagePath, "${fromLib.codeId}_flutter.dart");
      imports.addAll(import.lines);      
    }

    fileTheme.addImports(context, imports);

    // add the line that installs it
    final fileDefineUI = generator.modifyFile(context, generator.pathDefineCore);
    final defineTheme = DeclareDefineThemeT().toBuffer(context);
    defineTheme.replaceText(context, AFUISourceTemplateID.textThemeType, uiName);
    defineTheme.replaceText(context, AFUISourceTemplateID.textThemeID, parentThemeID);
    fileDefineUI.addLinesAfter(context, AFCodeRegExp.startDefineThemes, defineTheme.lines);
    if(imports.isNotEmpty) {
      fileDefineUI.addLinesBefore(context, AFCodeRegExp.startDefineCore, imports);
      if(fromLib != null) {
        generator.addImportIDFile(context,
          libraryId: fromLib,
          to: fileDefineUI,
        );
      }

    }

    generator.addImport(context, 
      importPath: fileTheme.importPathStatement, 
      to: fileDefineUI,
    );

    if(!isOverride) {
      generator.addExportsForFiles(context, args, [fileTheme]);
    }
    
    return fileTheme;
  }

  static AFGeneratedFile createScreen(AFCommandContext context, String uiName, Map<String, dynamic> args, {
    AFSourceTemplate? buildWithSPI,
    AFSourceTemplate? buildBody,
    AFSourceTemplate? spiImpls,
    AFSourceTemplate? screenImpls,
    AFSourceTemplate? routeParamImpls,
    AFSourceTemplate? navigatePush,
    AFSourceTemplate? createPrototype,
  }) {
    AFUIControlSettings? controlSettings;

    for(final candidateControlKind in controlKinds) {
      if(candidateControlKind.matchesName(uiName)) {
        controlSettings = candidateControlKind;
        break;
      }
    }
        

    if(controlSettings == null) {
      throw AFCommandError(error: "$uiName must end with one of $controlKinds");
    }

    final ns = AFibD.config.appNamespace.toUpperCase();
    final generator = context.generator;

    final minLength = ns.length + controlSettings.suffix.length;
    if(uiName.length <= minLength) {
      throw AFCommandError(error: "$uiName is too short.  It maybe the name of an existing default class.  Please differentiate it.");
    }

    final screenIdType = "$ns${controlSettings.suffix}ID";
    final spiParentType = "$ns${controlSettings.suffix}SPI";

    // create a screen name
    final projectPath = generator.pathUI(uiName, controlSettings);
    final imports = <String>[];
    final stateView = args[argStateView];
    final theme = args[argTheme];
    final stateViewPrefix = generator.removeSuffix(stateView, "StateView");

    final screenId = generator.declareUIID(context, uiName, controlSettings);

    final screenInsertions = context.coreInsertions?.reviseAugment({
      ScreenT.insertScreenID: screenId,
      ScreenT.insertScreenIDType: screenIdType,
      ScreenT.insertControlTypeSuffix: controlSettings.suffix,
      AFSourceTemplate.insertMainTypeInsertion: uiName,      
      ScreenT.insertStateViewType: stateView,
      ScreenT.insertStateViewPrefix: stateViewPrefix,
    });

    /*
    screenFile.replaceText(context, AFUISourceTemplateID.textScreenID, screenId);
    screenFile.replaceText(context, AFUISourceTemplateID.textScreenIDType, screenIdType);
    screenFile.replaceText(context, AFUISourceTemplateID.textSPIParentType, spiParentType);
    screenFile.replaceText(context, AFUISourceTemplateID.textThemeType, theme);

    final templateSPIImpls = spiImpls?.toBuffer(context) ?? controlSettings.implsSPI.toBuffer(context);
    templateSPI.replaceTextLines(context, AFUISourceTemplateID.textSPIImpls, templateSPIImpls.lines);
    screenFile.replaceTextLines(context, AFUISourceTemplateID.stmtDeclareSPI, templateSPI.lines);
    */

    final routeParamTemplate = routeParamImpls ?? controlSettings.routeParamImpls;
    final routeParamSnippet = context.createSnippet(routeParamTemplate, extend: screenInsertions);

    final navigatePushTemplate = (navigatePush ?? controlSettings.navigatePush);
    final navigatePushSnippet = context.createSnippet(navigatePushTemplate, extend: screenInsertions);

    final spiSnippet = context.createSnippet(controlSettings.spi, extend: screenInsertions, insertions: {
      AFSourceTemplate.insertMainParentTypeInsertion: spiParentType,
    });

    final superSnippet = context.createSnippet(controlSettings.implsSuper, extend: screenInsertions);

    final templateBody = buildBody ?? controlSettings.implBuildBody;
    final bodySnippet = context.createSnippet(templateBody, extend: screenInsertions);

    final buildWithSPITemplate = buildWithSPI ?? controlSettings.implBuildWithSPI;
    final buildWithSPISnippet = context.createSnippet(buildWithSPITemplate, extend: screenInsertions);

    final screenImplsSnippet = context.createSnippet(screenImpls ?? AFSourceTemplate.empty, extend: screenInsertions);

    final screenFile = context.createFile(projectPath, ScreenT(), extend: screenInsertions, insertions: {
      ScreenT.insertControlTypeSuffix: controlSettings.suffix,
      ScreenT.insertDeclareRouteParam: routeParamSnippet,
      ScreenT.insertDeclareSPI: spiSnippet,
      ScreenT.insertNavigateMethods: navigatePushSnippet,
      ScreenT.insertBuildBodyImpl: bodySnippet,
      ScreenT.insertBuildWithSPIImpl: buildWithSPISnippet,
      AFSourceTemplate.insertSuperParamsInsertion: superSnippet,
      AFSourceTemplate.insertConstructorParamsInsertion: controlSettings.paramsConstructor,
      AFSourceTemplate.insertAdditionalMethodsInsertion: screenImplsSnippet,
    });

    generator.addImportsForPath(context, generator.pathConnectedBaseFile, imports: imports);
    final pathStateView = generator.pathStateView(stateView);
    if(pathStateView != null) {
      generator.addImportsForPath(context, pathStateView, imports: imports);
    }

    final pathTheme = generator.pathTheme(theme, isCustomParent: false);
    if(pathTheme != null) {
      generator.addImportsForPath(context, pathTheme, imports: imports);    
    }

    screenFile.addImports(context, imports);
    
    // put the screen in the screen map
    if(controlSettings.kind != AFUIControlKind.widget) {
      final declareScreenInMap = DeclareRegisterScreenMapT().toBuffer(context);
      declareScreenInMap.replaceText(context, AFUISourceTemplateID.textScreenName, uiName);
      declareScreenInMap.replaceText(context, AFUISourceTemplateID.textScreenID, screenId);
      declareScreenInMap.replaceText(context, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
      declareScreenInMap.executeStandardReplacements(context);
      final screenMapPath = generator.pathDefineCore;
      final screenMapFile = generator.modifyFile(context, screenMapPath);
      screenMapFile.addLinesAfter(context, AFCodeRegExp.startScreenMap, declareScreenInMap.lines);
      generator.addImport(context, 
        importPath: screenFile.importPathStatement, 
        to: screenMapFile, 
      );            
    }

    // create a state test shortcut declaration function.
    final shortcut = controlSettings.stateTestShortcut.toBuffer(context);
    shortcut.replaceText(context, AFUISourceTemplateID.textScreenName, uiName);
    shortcut.replaceText(context, AFUISourceTemplateID.textScreenID, screenId);
    shortcut.replaceText(context, AFUISourceTemplateID.textScreenIDType, screenIdType);
    shortcut.replaceText(context, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
    final shortcutsFile = generator.modifyFile(context, generator.pathStateTestShortcutsFile);
    shortcutsFile.addLinesAfter(context, AFCodeRegExp.startShortcutsClass, shortcut.lines);

    // import the screen to the state test shortcuts.
    generator.addImport(context,
      importPath: screenFile.importPathStatement, 
      to: shortcutsFile,
    );

    // add exports for files
    final isStartupScreen = uiName == AFGenerateUISubcommand.nameStartupScreen;
    if(isStartupScreen) {
      generator.addExportsForFiles(context, args, [
        screenFile
      ]);

      generator.declareUIIDDirect(context, AFGenerateUISubcommand.nameButtonIncrementRouteParam, controlSettingsWidget);
      generator.declareUIIDDirect(context, AFGenerateUISubcommand.nameTextCountRouteParam, controlSettingsWidget);      
    }

    final generatePrototypes = AFibD.config.generateUIPrototypes;
    if(generatePrototypes) {
      // create a new screen test files
      final pathScreenTest = generator.pathScreenTest(uiName, controlSettings);
      final screenTestFile = generator.createFile(context, pathScreenTest, AFUISourceTemplateID.fileScreenTest);
      screenTestFile.replaceTemplate(context, AFUISourceTemplateID.textDeclareCreatePrototype, createPrototype ?? controlSettings.createPrototype);
      screenTestFile.replaceText(context, AFUISourceTemplateID.textScreenName, uiName);
      screenTestFile.replaceText(context, AFUISourceTemplateID.textFullTestDataID, generator.stateFullLoginID);
      screenTestFile.replaceText(context, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
      screenTestFile.replaceText(context, AFUISourceTemplateID.textScreenID, screenId);
      AFSourceTemplate templateUITestImpl = AFSourceTemplate.empty;
      if(isStartupScreen) {
        templateUITestImpl = DeclareStartupScreenTestImplT();
      }
      screenTestFile.replaceTemplate(context, AFUISourceTemplateID.declareSmokeTestImpl, templateUITestImpl);

      screenTestFile.executeStandardReplacements(context);
      generator.addImport(context,
        importPath: screenFile.importPathStatement,
        to: screenTestFile,
      );

      final protoName = "${uiName}InitialPrototype";
      final protoId = generator.declarePrototypeID(context, protoName);
      screenTestFile.replaceText(context, AFUISourceTemplateID.textScreenTestID, protoId);

      // add in a link to the defining function to the main tests file.
      final pathScreenTests = generator.pathScreenTests;
      final screenTestsFile = generator.modifyFile(context, pathScreenTests);

      // add the imports
      generator.addImport(context,
        importPath: screenTestFile.importPathStatement,
        to: screenTestsFile,
      );

      final callFunction = DeclareCallDefineScreenTest().toBuffer(context);
      callFunction.replaceText(context, AFUISourceTemplateID.textScreenName, uiName);
      screenTestsFile.addLinesAfter(context, AFCodeRegExp.startDefineScreenTestsFunction, callFunction.lines);
    }

    return screenFile;
  }

}
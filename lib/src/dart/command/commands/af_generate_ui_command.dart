import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';
import 'package:afib/src/dart/command/templates/core/files/screen_test.t.dart';
import 'package:afib/src/dart/command/templates/core/files/theme.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_bottom_sheet_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_call_define_screen_test.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_create_screen_prototype.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_create_widget_prototype.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_screen_map_entry.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_define_theme.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_dialog_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_drawer_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_drawer_extra_config_params.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_empty_screen_build_body_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_extra_imports.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_no_scaffold_build_with_spi.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_additional_methods.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_build_with_spi_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_screen_impls_super.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_smoke_test_impl.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_spi_on_pressed_closed.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_spi_on_tap_close.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_standard_route_param.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_state_test_screen_shortcut.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_state_test_widget_shortcut.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_build_body.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_impls_super.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_params_constructor.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_widget_route_param.t.dart';
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
  final Object implBuildWithSPI;
  final Object implBuildBody;
  final Object implsSPI;
  final Object implsSuper;
  final Object paramsConstructor;
  final Object routeParamImpls;
  final Object navigatePush;
  final Object spi;
  final Object stateTestShortcut;
  final Object createPrototype;
  final Object screenAdditionalMethods;
  final Object extraConfigParams;
  final Object smokeTestImpl;

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
    required this.screenAdditionalMethods,
    required this.spi,
    required this.stateTestShortcut,
    required this.createPrototype,
    required this.extraConfigParams,
    required this.smokeTestImpl,

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
      implBuildWithSPI: SnippetNoScaffoldBuildWithSPIImplT(),
      implBuildBody: SnippetWidgetBuildBodyT.core(),
      implsSPI: AFSourceTemplate.empty,
      implsSuper: SnippetWidgetImplsSuperT(),
      paramsConstructor: SnippetWidgetParamsConstructorT(),
      routeParamImpls: SnippetWidgetRouteParamT.core(),
      navigatePush: AFSourceTemplate.empty,
      spi: SnippetDeclareSPIT.core(),
      stateTestShortcut: SnippetStateTestWidgetShortcutT(),
      createPrototype: SnippetCreateWidgetPrototypeT(),
      screenAdditionalMethods: SnippetScreenAdditionalMethodsT(),
      extraConfigParams: AFSourceTemplate.empty,
      smokeTestImpl: SnippetSmokeTestImplT()
    );

  static final controlKinds = [
    AFUIControlSettings(
      kind: AFUIControlKind.screen, 
      suffix: screenSuffix, 
      path: AFCodeGenerator.screensPath,
      implBuildWithSPI: SnippetScreenBuildWithSPIImplT(),
      implBuildBody: SnippetMinimalScreenBuildBodyImplT(),
      implsSPI: AFSourceTemplate.empty,
      implsSuper: SnippetScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT.core(),
      navigatePush: SnippetNavigatePushT.core(),
      spi: SnippetDeclareSPIT.core(),
      stateTestShortcut: SnippetStateTestScreenShortcutT(),
      createPrototype: SnippetCreateScreenPrototypeT.noPushParams(),
      screenAdditionalMethods: SnippetScreenAdditionalMethodsT(),
      extraConfigParams: AFSourceTemplate.empty,
      smokeTestImpl: SnippetSmokeTestImplT(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.bottomSheet, 
      suffix: bottomSheetSuffix, 
      path: AFCodeGenerator.bottomSheetsPath,
      implBuildWithSPI: SnippetNoScaffoldBuildWithSPIImplT(),
      implBuildBody: SnippetBottomSheetBuildBodyT(),
      implsSPI: SnippetSPIOnPressedCloseImplT(),
      implsSuper: SnippetScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT.core(),
      navigatePush: SnippetNavigatePushT.core(),
      spi: SnippetDeclareSPIT.core(),
      stateTestShortcut: SnippetStateTestScreenShortcutT(),
      createPrototype: SnippetCreateScreenPrototypeT.noPushParams(),
      screenAdditionalMethods: SnippetScreenAdditionalMethodsT(),
      extraConfigParams: AFSourceTemplate.empty,
      smokeTestImpl: SnippetSmokeTestImplRequireCloseT()
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.drawer, 
      suffix: drawerSuffix, 
      path: AFCodeGenerator.drawersPath,
      implBuildWithSPI: SnippetNoScaffoldBuildWithSPIImplT(),
      implBuildBody: SnippetDrawerBuildBodyT(),
      implsSPI: SnippetSPIOnTapCloseT(),
      implsSuper: SnippetScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT.core(),
      navigatePush: SnippetNavigatePushT.core(),
      spi: SnippetDeclareSPIT.core(),
      stateTestShortcut: SnippetStateTestScreenShortcutT(),
      createPrototype: SnippetCreateScreenPrototypeT.noPushParams(),
      screenAdditionalMethods: SnippetScreenAdditionalMethodsT(),
      extraConfigParams: SnippetDrawerExtraConfigParamsT(),
      smokeTestImpl: SnippetSmokeTestImplRequireCloseT()
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.dialog, 
      suffix: dialogSuffix, 
      path: AFCodeGenerator.dialogsPath,
      implBuildWithSPI: SnippetNoScaffoldBuildWithSPIImplT(),
      implBuildBody: SnippetDialogBuildBodyT(),
      implsSPI: SnippetSPIOnPressedCloseImplT(),
      implsSuper: SnippetScreenImplsSuperT(),
      paramsConstructor: AFSourceTemplate.empty,
      routeParamImpls: SnippetStandardRouteParamT.core(),
      navigatePush: SnippetNavigatePushT.core(),
      spi: SnippetDeclareSPIT.core(),
      stateTestShortcut: SnippetStateTestScreenShortcutT(),
      createPrototype: SnippetCreateScreenPrototypeT.noPushParams(),
      screenAdditionalMethods: SnippetScreenAdditionalMethodsT(),
      extraConfigParams: AFSourceTemplate.empty,
      smokeTestImpl: SnippetSmokeTestImplRequireCloseT()
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

  --$argExportTemplatesHelp
  --$argOverrideTemplatesHelp
  ${AFCommand.argPrivateOptionHelp}
  
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {

    final generator = context.generator;
    final args = context.parseArguments(
      command: this, 
      unnamedCount: 1, 
      named: {
        argStateView: generator.nameDefaultStateView,
        argTheme: generator.nameDefaultTheme,
        argParentTheme: generator.nameDefaultParentTheme,
        argParentThemeID: generator.nameDefaultParentThemeID        
      }
    );


    final uiName = args.accessUnnamedFirst;
    verifyMixedCase(uiName, "ui name");
    verifyNotOption(uiName);

    if(uiName.endsWith("Theme")) {
      createTheme(context, uiName, args);
    } else {
      createScreen(context, uiName, args);
    }

    // replace any default 
    generator.finalizeAndWriteFiles(context);

  }

  static AFGeneratedFile createTheme(AFCommandContext context, String uiName, AFCommandArgumentsParsed args, {
    String? fullId,
    AFLibraryID? fromLib,
  }) {
    final generator = context.generator;
    final parentTheme = args.accessNamed(argParentTheme);
    final parentThemeID = args.accessNamed(argParentThemeID);
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
    final fileTheme = context.createFile(pathTheme, ThemeT.core(), insertions: {
      AFSourceTemplate.insertMainTypeInsertion: uiName,
      AFSourceTemplate.insertMainParentTypeInsertion: parentTheme
    });
    final imports = <String>[];
    if(isCustomParent && fromLib != null) {
      var parentThemePackage = fromLib.name;
      final import = SnippetImportFromPackageT().toBuffer(context, insertions: {
        AFSourceTemplate.insertPackageNameInsertion: parentThemePackage,
        AFSourceTemplate.insertPackagePathInsertion: "${fromLib.codeId}_flutter.dart"
      });
      imports.addAll(import.lines);      
    }

    fileTheme.importAll(context, imports);

    // add the line that installs it
    final fileDefineUI = generator.modifyFile(context, generator.pathDefineCore);
    final defineTheme = context.createSnippet(SnippetCallDefineThemeT(), insertions: {
      SnippetCallDefineThemeT.insertThemeID: parentThemeID,
      SnippetCallDefineThemeT.insertThemeType: uiName,
    });
    fileDefineUI.addLinesAfter(context, AFCodeRegExp.startDefineThemes, defineTheme.lines);
    if(imports.isNotEmpty) {
      fileDefineUI.addLinesBefore(context, AFCodeRegExp.startDefineCore, imports);
      if(fromLib != null) {
        fileDefineUI.importIDFile(context, fromLib);
      }

    }

    fileDefineUI.importFile(context, fileTheme);

    if(!isOverride) {
      generator.addExportsForFiles(context, args, [fileTheme]);
    }
    
    return fileTheme;
  }

  static AFGeneratedFile createScreen(AFCommandContext context, String uiName, AFCommandArgumentsParsed args, {
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
    final stateView = args.accessNamed(argStateView);
    final stateViewPrefix = generator.removeSuffix(stateView, "StateView");

    final screenId = generator.declareUIID(context, uiName, controlSettings);

    final screenInsertions = context.coreInsertions.reviseAugment({
      ScreenT.insertScreenID: screenId,
      ScreenT.insertScreenIDType: screenIdType,
      ScreenT.insertControlTypeSuffix: controlSettings.suffix,
      AFSourceTemplate.insertMainTypeInsertion: uiName,      
      ScreenT.insertStateViewType: stateView,
      ScreenT.insertStateViewPrefix: stateViewPrefix,
    });


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

    final screenImplsSnippet = context.createSnippet(screenImpls ?? controlSettings.screenAdditionalMethods, extend: screenInsertions);

    final extraImports = context.createSnippet(SnippetExtraImportsT.core(), extend: screenInsertions);

    final screenFile = context.createFile(projectPath, ScreenT(), extend: screenInsertions, insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: extraImports,
      ScreenT.insertControlTypeSuffix: controlSettings.suffix,
      ScreenT.insertDeclareRouteParam: routeParamSnippet,
      ScreenT.insertDeclareSPI: spiSnippet,
      ScreenT.insertNavigateMethods: navigatePushSnippet,
      ScreenT.insertBuildBodyImpl: bodySnippet,
      ScreenT.insertBuildWithSPIImpl: buildWithSPISnippet,
      ScreenT.insertExtraConfigParams: controlSettings.extraConfigParams,
      AFSourceTemplate.insertSuperParamsInsertion: superSnippet,
      AFSourceTemplate.insertConstructorParamsInsertion: controlSettings.paramsConstructor,
      AFSourceTemplate.insertAdditionalMethodsInsertion: screenImplsSnippet,
    });

    screenFile.importProjectPath(context, generator.pathConnectedBaseFile);
    final pathStateView = generator.pathStateView(stateView);
    if(pathStateView != null) {
      screenFile.importProjectPath(context, pathStateView);
    }

    /*
    final pathTheme = generator.pathTheme(theme, isCustomParent: false);
    if(pathTheme != null) {
      screenFile.importProjectPath(context, pathTheme);    
    }
    */
    
    // put the screen in the screen map
    if(controlSettings.kind != AFUIControlKind.widget) {
      final declareScreenInMap = context.createSnippet(SnippetDefineScreenMapEntryT(), extend: screenInsertions);

      final screenMapPath = generator.pathDefineCore;
      final screenMapFile = generator.modifyFile(context, screenMapPath);
      screenMapFile.addLinesAfter(context, AFCodeRegExp.startScreenMap, declareScreenInMap.lines);
      screenMapFile.importFile(context, screenFile);
    }

    // create a state test shortcut declaration function.
    final createShortcut = controlSettings.stateTestShortcut as AFSourceTemplate;
    final shortcut = context.createSnippet(createShortcut, extend: screenInsertions);
    final shortcutsFile = generator.modifyFile(context, generator.pathStateTestShortcutsFile);
    shortcutsFile.addLinesAfter(context, AFCodeRegExp.startShortcutsClass, shortcut.lines);

    // import the screen to the state test shortcuts.
    shortcutsFile.importFile(context, screenFile);

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
      final smokeTestImpl = context.createSnippet(controlSettings.smokeTestImpl);

      // create a new screen test files
      final protoName = "${uiName}InitialPrototype";
      final protoId = generator.declarePrototypeID(context, protoName);
      final pathScreenTest = generator.pathScreenTest(uiName, controlSettings);
      final createProto = createPrototype ?? controlSettings.createPrototype;
      final screenTestFile = context.createFile(pathScreenTest, ScreenTestT.core(), insertions: {
          AFSourceTemplate.insertExtraImportsInsertion: "",
          AFSourceTemplate.insertMainTypeInsertion: uiName,
          ScreenT.insertScreenID: protoId,
          ScreenT.insertControlTypeSuffix: controlSettings.suffix,
          ScreenTestT.insertDeclarePrototype: createProto,
          ScreenTestT.insertSmokeTestImpl: smokeTestImpl,
          SnippetCreateScreenPrototypeT.insertFullTestDataID: generator.stateFullLoginID,
      });

      screenTestFile.importFile(context, screenFile);

      // add in a link to the defining function to the main tests file.
      final pathScreenTests = generator.pathScreenTests;
      final screenTestsFile = generator.modifyFile(context, pathScreenTests);

      // add the imports
      screenTestsFile.importFile(context, screenTestFile);

      final callFunction = context.createSnippet(SnippetCallDefineScreenTest(), extend: screenInsertions);
      screenTestsFile.addLinesAfter(context, AFCodeRegExp.startDefineScreenTestsFunction, callFunction.lines);
    }

    return screenFile;
  }

}
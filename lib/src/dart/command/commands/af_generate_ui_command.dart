import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/comments/navigate_push_intro.t.dart';
import 'package:afib/src/dart/command/templates/files/theme.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_bottom_sheet_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_define_screen_test.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_create_screen_prototype.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_create_widget_prototype.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_navigate_push.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_theme.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_dialog_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_drawer_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_empty_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_launch_param_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_no_scaffold_build_with_spi.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_body_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_with_spi_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_impls_super.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_map_entry.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi_on_pressed_closed.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi_on_tap_close.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_standard_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_test_screen_shortcut.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_test_widget_shortcut.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_impls_super.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_params_constructor.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_widget_spi.t.dart';
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
  static final controlKinds = [
    AFUIControlSettings(
      kind: AFUIControlKind.screen, 
      suffix: screenSuffix, 
      path: AFCodeGenerator.screensPath,
      implBuildWithSPI: DeclareScreenBuildWithSPIImplT(),
      implBuildBody: DeclareScreenBuildBodyImplT(),
      implsSPI: DeclareEmptyStatementT(),
      implsSuper: DeclareScreenImplsSuperT(),
      paramsConstructor: DeclareEmptyStatementT(),
      routeParamImpls: DeclareStandardRouteParamImplsT(),
      navigatePush: DeclareDefineNavigatePushT(),
      spi: DeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.bottomSheet, 
      suffix: bottomSheetSuffix, 
      path: AFCodeGenerator.bottomSheetsPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareBottomSheetBuildBodyImplT(),
      implsSPI: DeclareSPIOnPressedCloseImplT(),
      implsSuper: DeclareScreenImplsSuperT(),
      paramsConstructor: DeclareEmptyStatementT(),
      routeParamImpls: DeclareStandardRouteParamImplsT(),
      navigatePush: DeclareDefineNavigatePushT(),
      spi: DeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.drawer, 
      suffix: drawerSuffix, 
      path: AFCodeGenerator.drawersPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareDrawerBuildBodyImplT(),
      implsSPI: DeclareSPIOnTapCloseImplT(),
      implsSuper: DeclareLaunchParamImplT(),
      paramsConstructor: DeclareEmptyStatementT(),
      routeParamImpls: DeclareStandardRouteParamImplsT(),
      navigatePush: DeclareDefineNavigatePushT(),
      spi: DeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.dialog, 
      suffix: dialogSuffix, 
      path: AFCodeGenerator.dialogsPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareDialogBuildBodyImplT(),
      implsSPI: DeclareSPIOnPressedCloseImplT(),
      implsSuper: DeclareScreenImplsSuperT(),
      paramsConstructor: DeclareEmptyStatementT(),
      routeParamImpls: DeclareStandardRouteParamImplsT(),
      navigatePush: DeclareDefineNavigatePushT(),
      spi: DeclareSPIT(),
      stateTestShortcut: DeclareStateTestScreenShortcutT(),
      createPrototype: DeclareCreateScreenPrototypeT(),
    ),
    AFUIControlSettings(
      kind: AFUIControlKind.widget, 
      suffix: widgetSuffix, 
      path: AFCodeGenerator.widgetsPath,
      implBuildWithSPI: DeclareNoScaffoldBuildWithSPIImplT(),
      implBuildBody: DeclareWidgetBuildBodyImplT(),
      implsSPI: DeclareEmptyStatementT(),
      implsSuper: DeclareWidgetImplsSuperT(),
      paramsConstructor: DeclareWidgetParamsConstructorT(),
      routeParamImpls: DeclareWidgetRouteParamImplsT(),
      navigatePush: DeclareEmptyStatementT(),
      spi: DeclareWidgetSPIT(),
      stateTestShortcut: DeclareStateTestWidgetShortcutT(),
      createPrototype: DeclareCreateWidgetPrototypeT(),
    ),
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
  void execute(AFCommandContext ctx) {
    final unnamed = ctx.unnamedArguments;
    if(unnamed == null || unnamed.isEmpty) {
      throwUsageError("You must specify at least the screen name.");
    }

    final uiName = unnamed[0];
    final generator = ctx.generator;
    final args = parseArguments(unnamed, defaults: {
      argStateView: generator.nameDefaultStateView,
      argTheme: generator.nameDefaultTheme,
      argParentTheme: generator.nameDefaultParentTheme,
      argParentThemeID: generator.nameDefaultParentThemeID
    });

    verifyMixedCase(uiName, "ui name");
    verifyNotOption(uiName);

    if(uiName.endsWith("Theme")) {
      createTheme(ctx, uiName, args);
    } else {
      createScreen(ctx, uiName, args);
    }

    // replace any default 
    generator.finalizeAndWriteFiles(ctx);

  }

  static AFGeneratedFile createTheme(AFCommandContext ctx, String uiName, Map<String, dynamic> args, {
    String? fullId,
    AFLibraryID? fromLib,
  }) {
    final generator = ctx.generator;
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
    final fileTheme = generator.createFile(ctx, pathTheme, AFThemeT());
    final imports = <String>[];
    if(isCustomParent && fromLib != null) {
      var parentThemePackage = fromLib.name;
      final import = ImportFromPackage().toBuffer();
      import.replaceText(ctx, AFUISourceTemplateID.textPackageName, parentThemePackage);
      import.replaceText(ctx, AFUISourceTemplateID.textPackagePath, "${fromLib.codeId}_flutter.dart");
      imports.addAll(import.lines);      
    }

    fileTheme.replaceText(ctx, AFUISourceTemplateID.textThemeType, uiName);
    fileTheme.replaceText(ctx, AFUISourceTemplateID.textParentThemeType, parentTheme ?? "AFFunctionalTheme");
    fileTheme.replaceTextLines(ctx, AFUISourceTemplateID.textImportStatements, imports);

    // add the line that installs it
    final fileDefineUI = generator.modifyFile(ctx, generator.pathDefineUI);
    final defineTheme = DeclareDefineThemeT().toBuffer();
    defineTheme.replaceText(ctx, AFUISourceTemplateID.textThemeType, uiName);
    defineTheme.replaceText(ctx, AFUISourceTemplateID.textThemeID, parentThemeID);
    fileDefineUI.addLinesAfter(ctx, AFCodeRegExp.startDefineThemes, defineTheme.lines);
    if(imports.isNotEmpty) {
      fileDefineUI.addLinesBefore(ctx, AFCodeRegExp.startDefineUI, imports);
      if(fromLib != null) {
        generator.addImportIDFile(ctx,
          libraryId: fromLib,
          to: fileDefineUI,
          before: AFCodeRegExp.startDefineUI,
        );
      }

    }

    generator.addImport(ctx, 
      importPath: fileTheme.importPathStatement, 
      to: fileDefineUI,
      before: AFCodeRegExp.startDefineUI
    );

    if(!isOverride) {
      generator.addExportsForFiles(ctx, args, [fileTheme]);
    }
    
    return fileTheme;
  }

  static AFGeneratedFile createScreen(AFCommandContext ctx, String uiName, Map<String, dynamic> args, {
    AFSourceTemplate? buildWithSPI,
    AFSourceTemplate? buildBody,
    AFSourceTemplate? spiImpls,
    AFSourceTemplate? screenImpls,
    AFSourceTemplate? routeParamImpls,
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
    final generator = ctx.generator;


    final screenIdType = "$ns${controlSettings.suffix}ID";
    final spiParentType = "$ns${controlSettings.suffix}SPI";

    // create a screen name
    final projectPath = generator.pathUI(uiName, controlSettings);
    final screenFile = generator.createFile(ctx, projectPath, AFUISourceTemplateID.fileScreen);

    final imports = <String>[];
    final stateView = args[argStateView];
    final theme = args[argTheme];
    final stateViewPrefix = generator.removeSuffix(stateView, "StateView");

    generator.addImportsForPath(ctx, generator.pathConnectedBaseFile, imports: imports);
    final pathStateView = generator.pathStateView(stateView);
    if(pathStateView != null) {
      generator.addImportsForPath(ctx, pathStateView, imports: imports);
    }
    final pathTheme = generator.pathTheme(theme, isCustomParent: false);
    if(pathTheme != null) {
      generator.addImportsForPath(ctx, pathTheme, imports: imports);    
    }
    final screenId = generator.declareUIID(ctx, uiName, controlSettings);

    final templateSPI = controlSettings.spi.toBuffer();

    final templateSPIImpls = spiImpls?.toBuffer() ?? controlSettings.implsSPI.toBuffer();
    templateSPI.replaceTextLines(ctx, AFUISourceTemplateID.textSPIImpls, templateSPIImpls.lines);
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.stmtDeclareSPI, templateSPI.lines);
    
    final templateSuper = controlSettings.implsSuper.toBuffer();
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textSuperImpls, templateSuper.lines);

    // create the screen file itself.
    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textStateViewType, stateView);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textScreenIDType, screenIdType);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textSPIParentType, spiParentType);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textThemeType, theme);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textStateViewPrefix, stateViewPrefix);
    screenFile.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textImportStatements, imports);
    screenFile.replaceTemplate(ctx, AFUISourceTemplateID.textBuildWithSPIImpl, buildWithSPI ?? controlSettings.implBuildWithSPI);
    final templateBody = buildBody ?? controlSettings.implBuildBody;
    final body = templateBody.toBuffer();
    body.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);

    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textBuildBodyImpl, body.lines);
    final routeParamTemplate = routeParamImpls ?? controlSettings.routeParamImpls;
    final routeParam = routeParamTemplate.toBuffer();
    routeParam.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
    routeParam.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
    routeParam.replaceText(ctx, AFUISourceTemplateID.textScreenIDType, screenIdType);
    routeParam.executeStandardReplacements(ctx);
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textRouteParamImpls, routeParam.lines);
    

    screenFile.replaceTemplate(ctx, AFUISourceTemplateID.textScreenImpls, screenImpls);

    screenFile.replaceTemplate(ctx, AFUISourceTemplateID.textParamsConstructor, controlSettings.paramsConstructor);
    
    final templatePush = controlSettings.navigatePush.toBuffer();
    templatePush.replaceTemplate(ctx, AFUISourceTemplateID.commentNavigatePush, NavigatePushIntroComment());
    templatePush.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);

    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textNavigateMethods, templatePush.lines);




    // put the screen in the screen map
    if(controlSettings.kind != AFUIControlKind.widget) {
      final declareScreenInMap = DeclareRegisterScreenMapT().toBuffer();
      declareScreenInMap.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
      declareScreenInMap.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
      declareScreenInMap.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
      declareScreenInMap.executeStandardReplacements(ctx);
      final screenMapPath = generator.pathDefineUI;
      final screenMapFile = generator.modifyFile(ctx, screenMapPath);
      screenMapFile.addLinesAfter(ctx, AFCodeRegExp.startScreenMap, declareScreenInMap.lines);
      generator.addImport(ctx, 
        importPath: screenFile.importPathStatement, 
        to: screenMapFile, 
        before: AFCodeRegExp.startDefineUI
      );            
    }

    // create a state test shortcut declaration function.
    final shortcut = controlSettings.stateTestShortcut.toBuffer();
    shortcut.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
    shortcut.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
    shortcut.replaceText(ctx, AFUISourceTemplateID.textScreenIDType, screenIdType);
    shortcut.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
    final shortcutsFile = generator.modifyFile(ctx, generator.pathStateTestShortcutsFile);
    shortcutsFile.addLinesAfter(ctx, AFCodeRegExp.startShortcutsClass, shortcut.lines);

    // import the screen to the state test shortcuts.
    generator.addImport(ctx,
      importPath: screenFile.importPathStatement, 
      to: shortcutsFile,
      before: AFCodeRegExp.startShortcutsClass
    );

    // add exports for files
    if(uiName != "StartupScreen") {
      generator.addExportsForFiles(ctx, args, [
        screenFile
      ]);
    }

    final generatePrototypes = AFibD.config.generateUIPrototypes;
    if(generatePrototypes) {
      // create a new screen test files
      final pathScreenTest = generator.pathScreenTest(uiName, controlSettings);
      final screenTestFile = generator.createFile(ctx, pathScreenTest, AFUISourceTemplateID.fileScreenTest);
      screenTestFile.replaceTemplate(ctx, AFUISourceTemplateID.textDeclareCreatePrototype, controlSettings.createPrototype);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textFullTestDataID, generator.stateFullLoginID);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);

      screenTestFile.executeStandardReplacements(ctx);
      generator.addImport(ctx,
        importPath: screenFile.importPathStatement,
        to: screenTestFile,
        before: AFCodeRegExp.startDefineScreenTestFunction
      );

      final protoName = "${uiName}InitialPrototype";
      final protoId = generator.declarePrototypeID(ctx, protoName);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textScreenTestID, protoId);

      // add in a link to the defining function to the main tests file.
      final pathScreenTests = generator.pathScreenTests;
      final screenTestsFile = generator.modifyFile(ctx, pathScreenTests);

      // add the imports
      generator.addImport(ctx,
        importPath: screenTestFile.importPathStatement,
        to: screenTestsFile,
        before: AFCodeRegExp.startDefineScreenTestsFunction
      );

      final callFunction = DeclareCallDefineScreenTest().toBuffer();
      callFunction.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
      screenTestsFile.addLinesAfter(ctx, AFCodeRegExp.startDefineScreenTestsFunction, callFunction.lines);
    }

    return screenFile;
  }

}
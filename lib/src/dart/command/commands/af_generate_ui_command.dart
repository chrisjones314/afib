import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/files/theme.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_bottom_sheet_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_call_define_screen_test.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_define_theme.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_dialog_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_drawer_build_body.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_empty_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_launch_param_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_no_scaffold_build_with_spi.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_body_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_build_with_spi_impl.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_screen_map_entry.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi_on_pressed_closed.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_spi_on_tap_close.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_standard_route_param_impls.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_state_test_screen_shortcut.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
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

  const AFUIControlSettings(
    this.kind,
    this.suffix,
    this.path,
    this.implBuildWithSPI,
    this.implBuildBody,
    this.implsSPI,
    this.implsSuper,
  );

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
      AFUIControlKind.screen, 
      screenSuffix, 
      AFCodeGenerator.screensPath,
      DeclareScreenBuildWithSPIImplT(),
      DeclareScreenBuildBodyImplT(),
      DeclareEmptyStatementT(),
      DeclareEmptyStatementT(),
    ),
    AFUIControlSettings(
      AFUIControlKind.bottomSheet, 
      bottomSheetSuffix, 
      AFCodeGenerator.bottomSheetsPath,
      DeclareNoScaffoldBuildWithSPIImplT(),
      DeclareBottomSheetBuildBodyImplT(),
      DeclareSPIOnPressedCloseImplT(),
      DeclareEmptyStatementT(),
    ),
    AFUIControlSettings(
      AFUIControlKind.drawer, 
      drawerSuffix, 
      AFCodeGenerator.drawersPath,
      DeclareNoScaffoldBuildWithSPIImplT(),
      DeclareDrawerBuildBodyImplT(),
      DeclareSPIOnTapCloseImplT(),
      DeclareLaunchParamImplT()
    ),
    AFUIControlSettings(
      AFUIControlKind.dialog, 
      dialogSuffix, 
      AFCodeGenerator.dialogsPath,
      DeclareNoScaffoldBuildWithSPIImplT(),
      DeclareDialogBuildBodyImplT(),
      DeclareSPIOnPressedCloseImplT(),
      DeclareEmptyStatementT(),
    ),
    AFUIControlSettings(
      AFUIControlKind.widget, 
      widgetSuffix, 
      AFCodeGenerator.widgetsPath,
      DeclareNoScaffoldBuildWithSPIImplT(),
      DeclareBottomSheetBuildBodyImplT(),
      DeclareEmptyStatementT(),
      DeclareEmptyStatementT(),
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
  $nameOfExecutable generate ui YourScreenName[${controlKinds.join('|')}] [any --options]

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

  static AFGeneratedFile createTheme(AFCommandContext ctx, String uiName, Map<String, dynamic> args) {
    final generator = ctx.generator;
    final parentTheme = args[argParentTheme];
    final String parentThemeID = args[argParentThemeID];
    final isCustomParent = parentTheme != generator.nameDefaultParentTheme;

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
    if(isCustomParent) {
      final idxThemeId = parentThemeID.indexOf("ThemeID.");
      if(idxThemeId < 0) {
        throw AFCommandError(error: "Expected --$argParentThemeID to contain ...ThemeID.");
      }

      final prefix = parentThemeID.substring(0, idxThemeId).toLowerCase();
      var parentThemePackage = AFibD.findLibraryWithPrefix(prefix)?.name;
      if(parentThemePackage == null) {
        parentThemePackage = args[argParentPackageName];
      }

      if(parentThemePackage == null) {
        throw AFCommandError(error: "Could not find an installed afib library with the prefix $prefix (maybe you need to run 'afib integrate'?");
      }
      final import = ImportFromPackage().toBuffer();
      import.replaceText(ctx, AFUISourceTemplateID.textPackageName, parentThemePackage);
      import.replaceText(ctx, AFUISourceTemplateID.textPackagePath, "${prefix}_flutter.dart");
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
    }

    generator.addImport(ctx, 
      importPath: fileTheme.importPathStatement, 
      to: fileDefineUI,
      before: AFCodeRegExp.startDefineUI
    );
    
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
    screenFile.replaceTemplate(ctx, AFUISourceTemplateID.textBuildBodyImpl, buildBody ?? controlSettings.implBuildBody);
    screenFile.replaceTemplate(ctx, AFUISourceTemplateID.textRouteParamImpls, routeParamImpls ?? DeclareStandardRouteParamImplsT());
    
    final templateSPI = spiImpls?.toBuffer() ?? controlSettings.implsSPI.toBuffer();
    templateSPI.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textSPIImpls, templateSPI.lines);

    final templateSuper = controlSettings.implsSuper.toBuffer();
    templateSuper.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
    screenFile.replaceTextLines(ctx, AFUISourceTemplateID.textSuperImpls, templateSuper.lines);
    screenFile.replaceTemplate(ctx, AFUISourceTemplateID.textScreenImpls, screenImpls);


    // put the screen in the screen map
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

    // create a state test shortcut declaration function.
    final shortcut = DeclareStateTestScreenShortcutT().toBuffer();
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
    generator.addExportsForFiles(ctx, args, [
      screenFile
    ]);

    final generatePrototypes = AFibD.config.generateUIPrototypes;
    if(generatePrototypes) {
      // create a new screen test files
      final pathScreenTest = generator.pathScreenTest(uiName, controlSettings);
      final screenTestFile = generator.createFile(ctx, pathScreenTest, AFUISourceTemplateID.fileScreenTest);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textScreenName, uiName);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textFullTestDataID, generator.stateFullLoginID);
      screenTestFile.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, controlSettings.suffix);
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
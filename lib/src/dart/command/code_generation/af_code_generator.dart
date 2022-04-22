import 'dart:io';

import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_generated_file.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/statements/declare_export_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:collection/collection.dart';
import 'package:colorize/colorize.dart';

class AFCodeGenerator { 
  static const afibConfigFile = "afib.g.dart";
  static const libFolder = "lib";
  static const uiFolder = "ui";
  static const initializationFolder = "initialization";
  static const screensFolder = "screens";
  static const stateFolder = "state";
  static const modelsFolder = "models";
  static const srcFolder = "src";
  static const queryFolder = "query";
  static const themesFolder = "themes";
  static const stateViewsFolder = "stateviews";
  static const testFolder = "test";
  static const uiPrototypesFolder = "ui_prototypes";
  static const bottomSheetsFolder = "bottomsheets";
  static const dialogsFolder = "dialogs";
  static const drawersFolder = "drawers";
  static const widgetsFolder = "widgets";
  static const binFolder = "bin";
  static const extendFolder = "extend";
  static const environmentsFolder = "environments";
  static const afibFolder = "afib";
  static const overrideFolder = "override";
  static const commandFolder = "command";

  static const testAFibPath = [testFolder, afibFolder];
  static const screensPath = [libFolder, uiFolder, screensFolder];
  static const bottomSheetsPath = [libFolder, uiFolder, bottomSheetsFolder];
  static const binPath = [binFolder];
  static const testsPath = [libFolder, testFolder];
  static const environmentsPath = [libFolder, initializationFolder, environmentsFolder];
  static const extendPath = [libFolder, initializationFolder, extendFolder];
  static const drawersPath = [libFolder, uiFolder, drawersFolder];
  static const dialogsPath = [libFolder, uiFolder, dialogsFolder];
  static const widgetsPath = [libFolder, uiFolder, widgetsFolder];
  static const modelsPath = [libFolder, stateFolder, modelsFolder];
  static const statePath = [libFolder, stateFolder];
  static const queryPath = [libFolder, queryFolder];
  static const commandPath = [libFolder, commandFolder];
  static const initializationPath = [libFolder, initializationFolder];
  static const libPath = [libFolder];
  static const uiPath = [libFolder, uiFolder];
  static const stateViewsPath = [libFolder, stateFolder, stateViewsFolder];
  static const themesPath = [libFolder, uiFolder, themesFolder];
  static const overrideThemesPath = [libFolder, overrideFolder, themesFolder];
  static const testPath = [libFolder, testFolder];
  static const prototypesPath = [libFolder, testFolder, uiPrototypesFolder];
  static const uiPrototypesFilename = "ui_prototypes.dart";

  final AFCommandAppExtensionContext definitions;
  final created = <String, AFGeneratedFile>{};
  final modified = <String, AFGeneratedFile>{};
  final renamed = <List<String>, List<String>>{};

  AFCodeGenerator({
    required this.definitions
  });

  List<String> get pathIdFile { 
    final idFile = "${appNamespace}_id.dart";
    return [libFolder, idFile];
  }

  List<String> get pathAfibConfig {
    final filename = "${appNamespace}_config.g.dart";
    return _createPath(initializationPath, filename);
  }

  String get appNamespace {
    return AFibD.config.appNamespace;
  }

  String get appNamespaceUpper {
    return AFibD.config.appNamespace.toUpperCase();
  }

  List<String> get pathDefineUI { 
    return _createPath(uiPath, "${appNamespace}_define_ui.dart");
  }

  List<String> get pathStateTestShortcutsFile {
    return _createPath(testPath, "${appNamespace}_state_test_shortcuts.dart");
  }

  List<String> pathUI(String uiName, AFUIControlSettings control) {
    final filename = "${convertMixedToSnake(uiName)}.dart";
    return _createPath(control.path, filename);
  }

  List<String> pathModel(String modelName) {
    final filename = "${convertMixedToSnake(modelName)}.dart";
    return _createPath(modelsPath, filename);
  }

  List<String> pathQuery(String modelName) {
    final filename = "${convertMixedToSnake(modelName)}.dart";
    return _createPath(queryPath, filename);
  }

  List<String>? pathStateView(String stateViewName) {
    final filename = _namedObjectToFilename(stateViewName, "StateView");
    if(filename == null) {
      return null;
    }
    return _createPath(stateViewsPath, filename);
  }

  List<String>? pathTheme(String themeName, { required bool isCustomParent }) {
    final filename = _namedObjectToFilename(themeName, "Theme");
    if(filename == null) {
      return null;
    }
    final path = isCustomParent ? overrideThemesPath : themesPath;
    return _createPath(path, filename);
    
  }

  List<String> pathScreenTest(String screenName, AFUIControlSettings control) {
    final filename = "${convertMixedToSnake(screenName)}_tests.dart";
    return _createPath(control.prototypesPath, filename);
  }

  List<String> get pathScreenTests {
    return _createPath(testPath, uiPrototypesFilename);
  }

  String get stateFullLoginID {
    return "stateFullLogin";
  }

  String? _namedObjectToFilename(String stateViewName, String suffix) {
    final ns = AFibD.config.appNamespace;
    final prefixUpper = ns.toUpperCase();
    if(!stateViewName.startsWith(prefixUpper)) {
      return null;
    }

    if(!stateViewName.endsWith(suffix)) {
      return null;
    }

    final internal = stateViewName.substring(prefixUpper.length);
    return "${ns}_${convertMixedToSnake(internal)}.dart";
  }

  List<String> get pathConnectedBaseFile {
    final filename = "${AFibD.config.appNamespace}_connected_base.dart";
    return _createPath(uiPath, filename);
  }

  List<String> get pathInstallUI {
    final filename = "${appNamespace}_install_ui.dart";
    return _createPath(libPath, filename);
  }

  List<String> get pathInstallCommand {
    final filename = "${appNamespace}_install_command.dart";
    return _createPath(libPath, filename);
  }

  List<String> pathCommand(String commandName) {
    final filename = "${convertMixedToSnake(commandName)}.dart";
    return _createPath(commandPath, filename);
  }

  List<String> get pathDefaultTheme {
    final filename = "${AFibD.config.appNamespace}_default_theme.dart";
    return _createPath(themesPath, filename);    
  }

  List<String> get pathFundamentalTheme {
    final filename = "${AFibD.config.appNamespace}_fundamental_theme.dart";
    return _createPath(themesPath, filename);    
  }

  List<String> get pathCreateDartParams {
    final filename = "create_dart_params.dart";
    return _createPath(initializationPath, filename);
  }

  List<String> get pathPubspecYaml {
    return ["pubspec.yaml"];
  }


  List<String> get pathExtendApplication {
    final filename = "application.dart";
    return _createPath(initializationPath, filename);
  }

  List<String> get pathExtendApp {
    final filename = "extend_app.dart";
    return _createPath(extendPath, filename);
  }

  List<String> get pathExtendTest {
    final filename = "extend_test.dart";
    return _createPath(extendPath, filename);
  }

  List<String> get pathMain {
    final filename = "main.dart";
    return _createPath(libPath, filename, underSrc: false);
  }

  List<String> get pathMainAFibTest {
    final filename = "main_afib_test.dart";
    return _createPath(testAFibPath, filename);
  }

  List<String> get pathTestData {
    final filename = "test_data.dart";
    return _createPath(testPath, filename);
  }

  List<String> pathTestDefinitions(String kind) {
    
    final filename = "${kind}s.dart";
    return _createPath(testsPath, filename);
  }

  List<String> get pathOriginalWidgetTest {
    return [testFolder, "widget_test.dart"];
  }

  List<String> get pathApp {
    final filename = "app.dart";
    return _createPath(libPath, filename);
  }

  List<String> get pathAppId {
    final filename = "${appNamespace}_id.dart";
    return _createPath(libPath, filename, underSrc: false);
  }

  String get nameStartupQuery {
    return "StartupQuery";
  }

  String get nameDefaultStateView {
    return "${appNamespaceUpper}DefaultStateView";
  }

  String get nameDefaultTheme {
    return "${appNamespaceUpper}DefaultTheme";
  }

  String get nameDefaultParentTheme {
    return "AFFunctionalTheme";
  }

  String get nameDefaultParentThemeID {
    return "${appNamespaceUpper}ThemeID.defaultTheme";
  }

  String get nameRootState {
    final defaultRootStateType = "${appNamespaceUpper}State";
    return defaultRootStateType;
  }

  List<String> get pathExtendBase {
    final filename = "extend_base.dart";
    return _createPath(extendPath, filename);
  }

  List<String> get pathStateModelAccess {
    final filename = "${appNamespace}_state_model_access.dart";
    return _createPath(statePath, filename);
  }

  List<String> get pathAppState {
    final filename = "${appNamespace}_state.dart";
    return _createPath(statePath, filename);
  }

  List<String> get pathExtendLibraryBase {
    final filename = "extend_base_library.dart";
    return _createPath(extendPath, filename);
  }

  List<String> get pathExtendCommand {
    final filename = "extend_command.dart";
    return _createPath(extendPath, filename);
  }

  List<String> get pathExtendLibraryCommand {
    final filename = "extend_command_library.dart";
    return _createPath(extendPath, filename);
  }

  List<String> get pathExtendLibraryUI {
    final filename = "extend_ui_library.dart";
    return _createPath(extendPath, filename);
  }


  List<String> get pathAppCommand {
    final filename = "${appNamespace}_afib.dart";
    return _createPath(binPath, filename);
  }

  List<String> pathEnvironment(String suffix) {
    final filename = "${suffix.toLowerCase()}.dart";
    return _createPath(environmentsPath, filename);
  }


  List<String> get pathFlutterExportsFile {
    final filename = "${AFibD.config.appNamespace}_flutter.dart";
    return [libFolder, filename];
  }

  List<String> get pathCommandExportsFile {
    final filename = "${AFibD.config.appNamespace}_command.dart";
    return [libFolder, filename];
  }

 List<String> pathRootState(String stateName) {
    final idx = stateName.indexOf("State");
    if(idx < 0) {
      throw AFException("Exepcted $stateName to end with 'State'");
    }
    final prefix = stateName.substring(0, idx);
    final filename = "${prefix.toLowerCase()}_state.dart";
    return _createPath(statePath, filename);
  }

  bool fileExists(List<String> projectPath) {
    final key = _keyForPath(projectPath);
    final inMem = _findInMemory(key);
    if(inMem != null) {
      return true;
    }

    if(AFProjectPaths.projectFileExists(projectPath)) {
      return true;
    }

    return false;
  }
  String importStatementPath(List<String> projectPath) {
    return importPathStatementStatic(projectPath);
  }

   bool addImportsForPath(AFCommandContext ctx, List<String> projectPath, { required List<String> imports, bool requireExists = true }) {
    if(!requireExists || fileExists(projectPath)) {
      final template = ImportFromPackage().toBuffer();
      template.replaceText(ctx, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
      template.replaceText(ctx, AFUISourceTemplateID.textPackagePath, importStatementPath(projectPath));
      imports.addAll(template.lines);
      return true;
    } 
    return false;
  }
  // void defineTestScreenTests(AFScreenTestDefinitionContext definitions) {
  // void\s+defineTestScreenTests(AFScreenTestDefinitionContext\s+definitions)\s+{

  void addImport(AFCommandContext ctx, {
    required String importPath,
    required AFGeneratedFile to,
    required RegExp before,
  }) {
    final declareImport = ImportFromPackage().toBuffer();
    declareImport.replaceText(ctx, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
    declareImport.replaceText(ctx, AFUISourceTemplateID.textPackagePath, importPath);
    to.addLinesBefore(ctx, before, declareImport.lines);

  }


  void addExportsForFiles(AFCommandContext context, Map<String, dynamic> args, List<AFGeneratedFile> files, {
    List<String>? toPath,
  }) {
    if(args[AFCommand.argPrivate]) {
      return;
    }
    if(!AFibD.config.isLibraryCommand) {
      return;
    }
    
    final pathExports = toPath ?? pathFlutterExportsFile;
    final fileExports = modifyFile(context, pathExports);
    for(final exportFile in files) {
      final decl = DeclareExportStatementT().toBuffer();
      decl.replaceText(context, AFUISourceTemplateID.textFileRelativePath, importPathStatementStatic(exportFile.projectPath));
      fileExports.addLinesAtEnd(context, decl.lines);
    }
  }


  String removeSuffix(String value, String suffix) {
    return value.substring(0, value.length - suffix.length);
  }

  static String importPathStatementStatic(List<String> projectPath) {
    final revised = List<String>.from(projectPath);
    if(revised[0] == AFProjectPaths.libFolder) {
      revised.removeAt(0);
    }
    return revised.join('/');
  }


  List<String> pathStateViewAccess() {
    final namespace = AFibD.config.appNamespace;
    final filename = "${namespace.toLowerCase()}_state_model_access.dart";
    return _createPath(statePath, filename);
  }

  List<String> _createPath(List<String> folders, String filename, { bool underSrc = true }) {
    return AFProjectPaths.createFile(folders, filename, underSrc: underSrc);
  }

  String packagePath(String packageName) {
    final result = StringBuffer(packageName);
    if(AFibD.config.isLibraryCommand) {
      result.write("/$srcFolder");
    }
    return result.toString();
  }

  List<String> pathState(String stateName) {
    final path = List<String>.from(statePath);
    path.add(stateName);
    return path;
  }

  void finalizeAndWriteFiles(AFCommandContext context) {
    for(final original in renamed.keys) {
      final revised = renamed[original];
      if(revised == null) {
        continue;
      }
      final output = context.output;
      output.startColumn(
        alignment: AFOutputAlignment.alignRight,
        width: 15,
        color: Styles.GREEN);
      output.write("rename ");
      output.startColumn(
        alignment: AFOutputAlignment.alignLeft
      );
      output.write(AFProjectPaths.relativePathFor(original));

      output.startColumn(
        alignment: AFOutputAlignment.alignLeft,
        width: 40,
      );
      output.write("-> ${AFProjectPaths.relativePathFor(revised)}");
      output.endLine();

      final pathOrig = AFProjectPaths.fullPathFor(original);
      final fileOrig = File(pathOrig);
      final pathRevised = AFProjectPaths.fullPathFor(revised);
      fileOrig.renameSync(pathRevised);
    }

    for(final generatedFile in created.values) {
      generatedFile.executeStandardReplacements(context);
      generatedFile.writeIfModified(context);
    }

    for(final modifiedFile in modified.values) {
      modifiedFile.writeIfModified(context);
    }
  }

  void renameExistingFileToOld(AFCommandContext context, List<String> projectPath) {
    if(!AFProjectPaths.projectFileExists(projectPath)) {
       throw AFCommandError(error: "Expected to find file at $projectPath but did not.");
    }

    final filename = projectPath.last;
    final idxSuffix = filename.lastIndexOf('.');
    if(idxSuffix < 0) {
      throw AFException("Expected $filename to have a . extension");
    }

    final renamedFilename = StringBuffer(filename.substring(0, idxSuffix));
    renamedFilename.write(".old");
    final revisedPath = List<String>.from(projectPath);
    revisedPath.removeLast();
    revisedPath.add(renamedFilename.toString());
    if(AFProjectPaths.projectFileExists(revisedPath)) {
      throw AFCommandError(error: "Need to rename $projectPath to $revisedPath, but the destination already exists");
    }

    renamed[projectPath] = revisedPath;        
  }

  // used for existing files which are loaded, modified and written back, the file must already exist
  AFGeneratedFile modifyFile(AFCommandContext context, List<String> projectPath) {
    return _modifyFile(context, projectPath);    
  }

  /// Used for generated files which always get overwritten.
  AFGeneratedFile overwriteFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId) {
    return _createFile(context, projectPath, templateOrId, AFGeneratedFileAction.overwrite);    
  }

  AFGeneratedFile createFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId) {    
    return _createFile(context, projectPath, templateOrId, AFGeneratedFileAction.create);
  }

  AFGeneratedFile _modifyFile(AFCommandContext context, List<String> projectPath) {
    return loadFile(context, projectPath);
  }

  bool isRenamed(List<String> projectPath) {
    Function eq = const ListEquality().equals;
    for(final candidate in renamed.keys) {
      if(eq(candidate, projectPath)) {
        return true;
      }
    }
    return false;
  }


  AFGeneratedFile _createFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId, AFGeneratedFileAction action) {
    // if not, return the contents of the template
    final templates = context.definitions.templates;
    var template;
    if(templateOrId is AFSourceTemplate) {
      template = templateOrId;
    } else {
      template = templates.find(templateOrId);
    }
    
    if(template == null) {
      throw AFException("Could not find template with id $templateOrId");
    }

    if(action == AFGeneratedFileAction.create && AFProjectPaths.projectFileExists(projectPath) && !isRenamed(projectPath)) {
      throw AFCommandError(error: "File at $projectPath needs to be created, but already exists, delete or move it if you'd like to re-create it.");
    }

    final result = AFGeneratedFile.fromTemplate(projectPath: projectPath, template: template, action: action);
    created[projectPath.join('/')] = result;
    result.resolveTemplateReferences(context: context);
    return result;
  }

  String removeSuffixAndCamel(String value, String suffix) {
    if(!value.endsWith(suffix)) {
      throw AFException("Expected $value to end with $suffix");
    }
    final prefix = value.substring(0, value.length-suffix.length);
    return toCamelCase(prefix);
  }

  String toCamelCase(String value) {
    return "${value[0].toLowerCase()}${value.substring(1)}";
  }

  String declareUIID(AFCommandContext ctx, String screenName, AFUIControlSettings control) {  
    return _declareID(ctx,
      name: screenName,
      suffix: control.suffix,
      after: AFCodeRegExp.startUIID(control.suffix),
    );    
  }

  String declarePrototypeID(AFCommandContext ctx, String screenName) {  
    return _declareID(ctx,
      name: screenName,
      suffix: "Prototype",
      after: AFCodeRegExp.startPrototypeID,
    );    
  }

  String _declareID(AFCommandContext ctx, {
    required String name,
    required String suffix,
    required RegExp after,
  }) {
    final idPath = pathIdFile;
    final idFile = loadFile(ctx, idPath);
    final root = removeSuffix(name, suffix);
    final screenId = toCamelCase(root);
    
    final declareId = DeclareIDStatementT().toBuffer();
    declareId.replaceText(ctx, AFUISourceTemplateID.textScreenName, name);
    declareId.replaceText(ctx, AFUISourceTemplateID.textScreenID, screenId);
    declareId.replaceText(ctx, AFUISourceTemplateID.textControlTypeSuffix, suffix);
    declareId.executeStandardReplacements(ctx);
    idFile.addLinesAfter(ctx, after, declareId.lines);
    return screenId;    
  }

  String _keyForPath(List<String> path) {
    final key = path.join('/');
    return key;
  }

  AFGeneratedFile? _findInMemory(String key) {
    final current = modified[key];
    if(current != null) {
      return current;
    }
    final createdFile = created[key];
    if(createdFile != null) {
      return createdFile;
    }
    return null;
  }

  AFGeneratedFile loadFile(AFCommandContext context, List<String> path) {
    final key = _keyForPath(path);
    final inMem = _findInMemory(key);
    if(inMem != null) {
      return inMem;
    }
    final result = AFGeneratedFile.fromPath(projectPath: path);
    modified[key] = result;
    return result;
  }

  static String convertMixedToSnake(String convert) {
    final sb = StringBuffer();
    for(var i = 0; i < convert.length; i++) {
      final c = convert[i];
      if(c == c.toUpperCase()) {
        if(i > 0) {
          sb.write("_");
        }
        sb.write(c.toLowerCase());
      } else {
        sb.write(c);
      }
    }
    return sb.toString().toLowerCase();
  }  

  static String convertMixedToSpaces(String convert) {
    final sb = StringBuffer();
    for(var i = 0; i < convert.length; i++) {
      final c = convert[i];
      if(c == c.toUpperCase()) {
        if(i > 0) {
          sb.write(" ");
        }
      }
      sb.write(c);
    }
    return sb.toString();
  }  

  static String convertToCamelCase(String convert) {
    final sb = StringBuffer();
    for(var i = 0; i < convert.length; i++) {
      final c = convert[i];
      if(i == 0) {
        sb.write(c.toLowerCase());
      } else {
        sb.write(c);
      }
    }
    return sb.toString();
  }  


  static String convertSnakeToMixed(String convert, { bool upcaseFirst = false } ) {
    final sb = StringBuffer();
    var shouldUpcase = upcaseFirst;
    for(var i = 0; i < convert.length; i++) {
      var c = convert[i];
      if(shouldUpcase) {
        c = c.toUpperCase(); 
      }
      if(c != "_") {
        sb.write(c);
        shouldUpcase = false;
      } else {
        shouldUpcase = true;
      }
    }
    return sb.toString();
  }

  static String toCapitalFirstLetter(String convert) {
    return "${convert[0].toUpperCase()}${convert.substring(1)}";
  }

}

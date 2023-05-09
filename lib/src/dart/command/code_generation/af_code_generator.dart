import 'dart:convert';
import 'dart:io';

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';
import 'package:afib/src/dart/command/code_generation/af_generated_file.dart';
import 'package:afib/src/dart/command/commands/af_generate_query_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_ui_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_export_statement.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_id_statement.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:collection/collection.dart';
import 'package:colorize/colorize.dart';
import 'package:path/path.dart';
import 'package:plural_noun/plural_noun.dart';

class AFCodeGenerator { 
  static const rootSuffix = "Root";
  static const stateViewSuffix = "StateView";
  static const lpiSuffix = "LPI";
  static const unitTestSuffix = "UnitTest";
  static const stateTestSuffix = "StateTest";
  static const wireframeSuffix = "Wireframe";

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
  static const installFolder = "install";
  static const environmentsFolder = "environments";
  static const afibFolder = "afib";
  static const overrideFolder = "override";
  static const commandFolder = "command";
  static const lpisFolder = "lpis";
  static const rootFolder = "root";
  static const stateTestsFolder = "state_tests";
  static const unitTestsFolder = "unit_tests";
  static const wireframesFolder = "wireframes";
  static const simpleFolder = "simple";
  static const deferredFolder = "deferred";
  static const listenerFolder = "listener";
  static const isolateFolder = "isolate";

  static const testAFibPath = [testFolder, afibFolder];
  static const screensPath = [libFolder, uiFolder, screensFolder];
  static const bottomSheetsPath = [libFolder, uiFolder, bottomSheetsFolder];
  static const binPath = [binFolder];
  static const testsPath = [libFolder, testFolder];
  static const environmentsPath = [libFolder, initializationFolder, environmentsFolder];
  static const installPath = [libFolder, initializationFolder, installFolder];
  static const drawersPath = [libFolder, uiFolder, drawersFolder];
  static const dialogsPath = [libFolder, uiFolder, dialogsFolder];
  static const widgetsPath = [libFolder, uiFolder, widgetsFolder];
  static const lpisPath = [libFolder, stateFolder, lpisFolder];
  static const lpisOverridePath = [libFolder, overrideFolder, lpisFolder];
  static const modelsPath = [libFolder, stateFolder, modelsFolder];
  static const rootsPath = [libFolder, stateFolder, rootFolder];
  static const statePath = [libFolder, stateFolder];
  static const queryPath = [libFolder, queryFolder];
  static const querySimplePath = [libFolder, queryFolder, simpleFolder];
  static const queryDeferredPath = [libFolder, queryFolder, deferredFolder];
  static const queryListenerPath = [libFolder, queryFolder, listenerFolder];
  static const queryIsolatePath = [libFolder, queryFolder, isolateFolder];
  static const commandPath = [libFolder, commandFolder];
  static const vsCodeFolder = ".vscode";
  static const vsCodePath = [vsCodeFolder];
  static const vsCodeExtenstionsPath = [vsCodeFolder, "extensions.json"];
  static const initializationPath = [libFolder, initializationFolder];
  static const libPath = [libFolder];
  static const uiPath = [libFolder, uiFolder];
  static const stateViewsPath = [libFolder, stateFolder, stateViewsFolder];
  static const themesPath = [libFolder, uiFolder, themesFolder];
  static const overrideThemesPath = [libFolder, overrideFolder, themesFolder];
  static const testPath = [libFolder, testFolder];
  static const prototypesPath = [libFolder, testFolder, uiPrototypesFolder];
  static const stateTestsPath = [libFolder, testFolder, stateTestsFolder];
  static const unitTestsPath = [libFolder, testFolder, unitTestsFolder];
  static const wireframesPath = [libFolder, testFolder, wireframesFolder];

  static const uiPrototypesFilename = "ui_prototypes.dart";

  final AFCommandAppExtensionContext definitions;
  final created = <String, AFGeneratedFile>{};
  final modified = <String, AFGeneratedFile>{};
  final renamed = <List<String>, List<String>>{};
  final ensuredFolders = <List<String>>[];

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

  List<String> get pathDefineCore { 
    return _createPath(initializationPath, "${appNamespace}_define_core.dart");
  }

  List<String> pathTests(String suffix) { 
    final suffixSnake = convertMixedToSnake("${suffix}s");
    return _createPath(testPath, "$suffixSnake.dart");
  }

  List<String> pathTest(String testName, String suffix) { 
    final filename = "${convertMixedToSnake(testName)}.dart";
    final suffixSnake = convertMixedToSnake("${suffix}s");
    final fullPath = testPath.toList();
    fullPath.add(suffixSnake);
    return _createPath(fullPath, filename);
  }

  List<String> get pathStateTestShortcutsFile {
    return _createPath(testPath, "${appNamespace}_state_test_shortcuts.dart");
  }

  List<String> pathUI(String uiName, AFUIControlSettings control) {
    final filename = "${convertMixedToSnake(uiName)}.dart";
    return _createPath(control.path, filename);
  }

  List<String>? pathModel(String modelName) {
    if(modelName.contains(".")) {
      return null;
    }
    final filename = "${convertMixedToSnake(modelName)}.dart";
    var path = modelsPath;
    if(modelName.endsWith(AFCodeGenerator.rootSuffix)) {
      path = rootsPath;
    }
    return _createPath(path, filename);
  }

  List<String>? pathUnknown(String name) {
    if(name.endsWith(AFGenerateQuerySubcommand.suffixQuery)) {
      return pathQuery(name);
    }

    final controlKind = AFGenerateUISubcommand.findControlKind(name);
    if(controlKind != null) {
      return pathUI(name, controlKind);
    }
    
    return pathModel(name);
  }

  List<String> pathModelFile(String filename) {
    return _createPath(modelsPath, filename);
  }

  List<String> pathLPI(String lpiName, { required bool isOverride}) {
    final shortened = removeSuffix(removePrefix(lpiName, appNamespaceUpper), "LPI");
    final filename = "${appNamespace}_${convertMixedToSnake(shortened)}_lpi.dart";
    return _createPath(isOverride ? lpisOverridePath : lpisPath, filename);
  }

  List<String> pathQuery(String modelName) {
    final filename = "${convertMixedToSnake(modelName)}.dart";
    var path = querySimplePath;
    if(modelName.endsWith(AFGenerateQuerySubcommand.suffixDeferredQuery)) {
      path = queryDeferredPath;
    } else if(modelName.endsWith((AFGenerateQuerySubcommand.suffixListenerQuery))) {
      path = queryListenerPath;
    } else if(modelName.endsWith(AFGenerateQuerySubcommand.suffixIsolateQuery)) {
      path = queryIsolatePath;
    } 
    return _createPath(path, filename);
  }

  List<String>? pathStateView(String stateViewName) {
    final filename = _namedObjectToFilename(stateViewName, "StateView");
    if(filename == null) {
      return null;
    }
    return _createPath(stateViewsPath, filename);
  }

  void ensureFolderExists(List<String> path) {

    final modifiedPath = path.toList();
    if(AFibD.config.isLibraryCommand && path.first == libFolder) {
      modifiedPath.insert(1, srcFolder);
    }

    ensuredFolders.add(modifiedPath);
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
    return "${AFibD.config.appNamespace}StateFullLogin";
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

  List<String> get pathInstall {
    final filename = "${appNamespace}_install_core.dart";
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

  List<String> get pathInstallCoreApp {
    final filename = "install_core_app.dart";
    return _createPath(installPath, filename);
  }

  List<String> get pathInstallTest {
    final filename = "install_test.dart";
    return _createPath(installPath, filename);
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

  List<String> get pathInstallBase {
    final filename = "install_base.dart";
    return _createPath(installPath, filename);
  }

  List<String> get pathStateModelAccess {
    final filename = "${appNamespace}_state_model_access.dart";
    return _createPath(statePath, filename);
  }

  List<String> get pathAppState {
    final filename = "${appNamespace}_state.dart";
    return _createPath(statePath, filename);
  }

  List<String> get pathInstallLibraryBase {
    final filename = "install_base_library.dart";
    return _createPath(installPath, filename);
  }

  List<String> get pathExtendCommand {
    final filename = "install_command.dart";
    return _createPath(installPath, filename);
  }

  List<String> get pathInstallLibraryCommand {
    final filename = "install_command_library.dart";
    return _createPath(installPath, filename);
  }

  List<String> get pathInstallLibraryCore {
    final filename = "install_core_library.dart";
    return _createPath(installPath, filename);
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

  /*
   bool addImportsForPath(AFCommandContext ctx, List<String> projectPath, { required List<String> imports, bool requireExists = true }) {
    if(!requireExists || fileExists(projectPath)) {
      final template = ctx.createSnippet(SnippetImportFromPackageT(), insertions: {
        AFSourceTemplate.insertPackagePathInsertion: importStatementPath(projectPath),
      });
      imports.addAll(template.lines);
      return true;
    } 
    return false;
  }
  */

  String deriveFullLibraryIDFromType(String parentType, String suffix, {
    String? typeKind
  }) {
    final lib = findLibraryForTypeWithPrefix(parentType);
    if(!parentType.endsWith(suffix)) {
      throw AFCommandError(error: "Expected $parentType to end with $suffix");
    }
    final libNamespace = lib.codeId.toUpperCase();
    var identifier = removeSuffixAndCamel(removePrefix(parentType, libNamespace), suffix);
    if(identifier == "default") {
      identifier = "$identifier$suffix";
    }
    return "$libNamespace${typeKind ?? suffix}ID.$identifier";
  }

  AFLibraryID findLibraryForTypeWithPrefix(String parentType) {
    // first, derive the prefix
    final libs = List<AFLibraryID>.from(AFibD.libraries);

    // sort them from longest to shortest, to be sure we don't take a short one that is a prefix
    // of a long one.
    libs.sort((l, r) => r.codeId.length.compareTo(l.codeId.length));

    for(final lib in libs) {
      if(parentType.startsWith(lib.codeId.toUpperCase())) {
        return lib;
      }
    }
    throw AFCommandError(error: "Expected $parentType to start with a valid library prefix: ${libs.map((l) => l.codeId.toUpperCase())}");
  }

  void addExportsForFiles(AFCommandContext context, AFCommandArgumentsParsed args, List<AFGeneratedFile> files, {
    List<String>? toPath,
  }) {
    final isPrivate = args.accessNamedFlag(AFCommand.argPrivate);
    if(isPrivate) {
      return;
    }
    if(!AFibD.config.isLibraryCommand) {
      return;
    }
    
    final pathExports = toPath ?? pathFlutterExportsFile;
    final fileExports = modifyFile(context, pathExports);
    for(final exportFile in files) {
      final decl = context.createSnippet(SnippetExportStatementT(), insertions: {
        SnippetExportStatementT.insertPath: importPathStatementStatic(exportFile.projectPath),
      });
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

  /*
  void outputThreeColumns(AFCommandContext context, 
    String col1,
    String col2, 
    String col3,
  ) {
    final output = context.output;
    output.startColumn(
      alignment: AFOutputAlignment.alignRight,
      width: 15,
      color: Styles.GREEN);
    output.write(col1);
    output.startColumn(
      alignment: AFOutputAlignment.alignLeft
    );
    output.write(col2);

    output.startColumn(
      alignment: AFOutputAlignment.alignLeft,
      width: 40,
    );
    output.write(col3);
    output.endLine();
  }
  */

  void finalizeAndWriteFiles(AFCommandContext context) {
    if(!context.isRootCommand) {
      return;
    }

    // verify that none of the files still contain [!af_] tags
    _validateNoAFTags(context, created.values);
    _validateNoAFTags(context, modified.values);

    final output = context.output;
    var renamedCount = 0;
    for(final original in renamed.keys) {
      final revised = renamed[original];
      if(revised == null) {
        continue;
      }

      if(context.isExportTemplates) {
        continue;
      }

      output.writeTwoColumns(col1: "rename ", col2: "${AFProjectPaths.relativePathFor(original)} -> ${AFProjectPaths.relativePathFor(revised)}");
      renamedCount++;

      final pathOrig = AFProjectPaths.fullPathFor(original);
      final fileOrig = File(pathOrig);
      final pathRevised = AFProjectPaths.fullPathFor(revised);
      fileOrig.renameSync(pathRevised);
    }


    var createdCount = 0;
    for(final generatedFile in created.values) {
      if(generatedFile.writeIfModified(context)) {
        createdCount++;
      }
    }

    var modifiedCount = 0;
    for(final modifiedFile in modified.values) {
      if(modifiedFile.writeIfModified(context)) {
        modifiedCount++;
      }
    }

    var createdFolderCount = 0;
    for(final folder in ensuredFolders) {
      if(!AFProjectPaths.projectFileExists(folder)) {
        createdFolderCount++;
        output.writeTwoColumns(col1: "create ", col2: AFProjectPaths.relativePathFor(folder));
        AFProjectPaths.createProjectFolder(folder);
      }
    }

    output.writeTwoColumns(col1: "success ", col2: "renamed $renamedCount files, created $createdCount files, modified $modifiedCount files, created $createdFolderCount folders");
  }

  static String pluralize(String source) {
    final tokens = AFCodeGenerator.splitMixedCase(source);
    final pluralLast = PluralRules().convertToPluralNoun(tokens.last);
    tokens[tokens.length-1] = pluralLast;
    final pluralIdentifier = tokens.join("");
    return pluralIdentifier;
  }

  void _validateNoAFTags(AFCommandContext context, Iterable<AFGeneratedFile> files) {
    for(final file in files) {
      final ci = context.coreInsertions;
      if(!context.isExportTemplates) {
        file.performInsertions(context, ci);
      }

      final afTag = file.findFirstAFTag();
      if(afTag != null && !context.isExportTemplates) {
        throw AFException("Internal error: $afTag [!af... tag still present in ${file.projectPath.join('/')}");
      }

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
  AFGeneratedFile overwriteFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId, {
    Map<AFSourceTemplateInsertion, AFSourceTemplate>? insertions,
  }) {
    final generated = _createFile(context, projectPath, templateOrId, AFGeneratedFileAction.overwrite);    
    if(insertions != null && !context.isExportTemplates) {
      final insert = AFSourceTemplateInsertions(insertions: insertions);
      generated.performInsertions(context, insert);
    }
    return generated;
  }

  AFGeneratedFile createFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId, {
    AFSourceTemplateInsertions? insertions,
  }) {
    // if we are generating templates, then generate it at the     
    final generated = _createFile(context, projectPath, templateOrId, AFGeneratedFileAction.create);
    if(insertions != null && !context.isExportTemplates) {
      generated.performInsertions(context, insertions);
    }
    return generated;
  }

  AFGeneratedFile readProjectStyle(AFCommandContext context, List<String> projectPath, dynamic templateOrId, {
    AFSourceTemplateInsertions? insertions,
  }) {
    // if we are generating templates, then generate it at the     
    final generated = _createFile(context, projectPath, templateOrId, AFGeneratedFileAction.projectStyle);
    if(insertions != null && !context.isExportTemplates) {
      generated.performInsertions(context, insertions);
    }
    return generated;
  }

  void writeJsonFileSync(AFCommandContext context, List<String> projectPath, Map<String, Object> json) {
    final generatedPath = projectPath.join(Platform.pathSeparator);
    final file = File(generatedPath);
    final encoded = jsonEncode(json);
    file.writeAsStringSync(encoded);
  }


  Map<String, Object> readJsonFileSync(AFCommandContext context, List<String> projectPath, Map<String, Object> defaultValue) {
    final generatedPath = projectPath.join(Platform.pathSeparator);
    final file = File(generatedPath);
    if(!file.existsSync()) {
      return defaultValue;
    }

    final contents = file.readAsStringSync();
    final json = jsonDecode(contents);
    return Map<String, Object>.from(json);
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
    
    if(action == AFGeneratedFileAction.create && AFProjectPaths.projectFileExists(projectPath) && !isRenamed(projectPath) && !context.isForceOverwrite) {
      throw AFCommandError(error: "File at '${joinAll(projectPath)}' needs to be created, but already exists, delete or move it if you'd like to re-create it.");
    }

    AFGeneratedFile generated;
    if(context.isExportTemplates) {
      if(templateOrId is! AFFileSourceTemplate) {
        throw AFException("Expected AFFileSourceTemplate");
      }

      generated = templateOrId.createGeneratedTemplate(context);
    } else if(template != null) {
      generated = AFGeneratedFile.fromTemplate(context: context, projectPath: projectPath, template: template, action: action);
    } else if(templateOrId is AFCodeBuffer) {
      generated = AFGeneratedFile.fromBuffer(projectPath: projectPath, buffer: templateOrId, action: action);
    } else {
      throw AFException("Could not find template with id $templateOrId");
    }

    final generatedPath = projectPath.join(Platform.pathSeparator);
    if(action != AFGeneratedFileAction.projectStyle || context.isExportTemplates) {
      created[generatedPath] = generated;
    }
    return generated;
  }

  String removePrefix(String value, String prefix) {
    if(!value.startsWith(prefix)) {
      throw AFException("Expected $value to start with $prefix");
    }
    final result = value.substring(prefix.length);
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

  String declareUIIDDirect(AFCommandContext context, String idName, AFUIControlSettings control) {
    final idPath = pathIdFile;
    final idFile = loadFile(context, idPath);
    final declareId = context.createSnippet(SnippetIDStatementT(), insertions: {
      ScreenT.insertScreenID: idName,
      ScreenT.insertControlTypeSuffix: control.suffix,
    });

    final suffixSuper = control.kind == AFUIControlKind.widget ? "Widget" : "Screen";
    final after = AFCodeRegExp.startUIID(control.suffix, suffixSuper);
    idFile.addLinesAfter(context, after, declareId.lines);
    return idName;
  }

  String declareUIID(AFCommandContext ctx, String screenName, AFUIControlSettings control) {  
    final suffixSuper = control.kind == AFUIControlKind.widget ? "Widget" : "Screen";
    return _declareID(ctx,
      name: screenName,
      suffix: control.suffix,
      after: AFCodeRegExp.startUIID(control.suffix, suffixSuper),
    );    
  }

  String declarePrototypeID(AFCommandContext ctx, String screenName) {  
    return _declareID(ctx,
      name: screenName,
      suffix: "Prototype",
      after: AFCodeRegExp.startPrototypeID,
    );    
  }

  String _declareID(AFCommandContext context, {
    required String name,
    required String suffix,
    required RegExp after,
  }) {
    final idPath = pathIdFile;
    final idFile = loadFile(context, idPath);
    final root = removeSuffix(name, suffix);
    final screenId = toCamelCase(root);
    
    final declareId = context.createSnippet(SnippetIDStatementT(), insertions: {
      ScreenT.insertScreenID: screenId,
      ScreenT.insertControlTypeSuffix: suffix,
      AFSourceTemplate.insertMainTypeInsertion: name,      
    });
    idFile.addLinesAfter(context, after, declareId.lines);
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
    final tokens = <String>[];
    final currentToken = StringBuffer();

    for(var i = 0; i < convert.length; i++) {
      final currentChar = convert[i];
      final isUpper = int.tryParse(currentChar) == null && currentChar == currentChar.toUpperCase();
      if(isUpper && i > 0) {
        final prevChar = convert[i-1];
        final prevIsUpper = prevChar == prevChar.toUpperCase();
        final nextChar = (i+1 < convert.length) ? convert[i+1] : prevChar;
        final nextIsUpper = nextChar == nextChar.toUpperCase();
        if(!prevIsUpper || !nextIsUpper) {
          tokens.add(currentToken.toString());
          currentToken.clear();
        }
      }

      currentToken.write(currentChar);
    }

    if(currentToken.isNotEmpty) {
      tokens.add(currentToken.toString());
    }

    final allLower = tokens.map((x) => x.toLowerCase());
    return allLower.join("_");
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

  static String convertStripId(String convert) {
    if(convert.endsWith("Id")) {
      convert = convert.substring(0, convert.length - 2);
    }
    return convert;
  }

  static String convertUpcaseFirst(String convert) {
    final first = convert.substring(0, 1);
    return "${first.toUpperCase()}${convert.substring(1)}";
  }

  static List<String> splitMixedCase(String convert) {
    final spaces = convertMixedToSpaces(convert);
    return spaces.split(" ");
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

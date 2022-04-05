import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_generated_file.dart';
import 'package:afib/src/dart/command/commands/af_generate_screen_command.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/statements/declare_export_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/declare_id_statement.t.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

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
  static const screensPath = [libFolder, uiFolder, screensFolder];
  static const bottomSheetsPath = [libFolder, uiFolder, bottomSheetsFolder];
  static const drawersPath = [libFolder, uiFolder, drawersFolder];
  static const dialogsPath = [libFolder, uiFolder, dialogsFolder];
  static const widgetsPath = [libFolder, uiFolder, widgetsFolder];
  static const modelsPath = [libFolder, stateFolder, modelsFolder];
  static const statePath = [libFolder, stateFolder];
  static const queryPath = [libFolder, queryFolder];
  static const libPath = [libFolder];
  static const uiPath = [libFolder, uiFolder];
  static const afibConfig = [libFolder, initializationFolder, afibConfigFile];
  static const stateViewsPath = [libFolder, uiFolder, stateViewsFolder];
  static const themesPath = [libFolder, uiFolder, themesFolder];
  static const testPath = [libFolder, testFolder];
  static const prototypesPath = [libFolder, testFolder, uiPrototypesFolder];
  static const uiPrototypesFilename = "ui_prototypes.dart";
  static const screenMapFilename = "screen_map.dart";

  final AFCommandExtensionContext definitions;
  final created = <String, AFGeneratedFile>{};
  final modified = <String, AFGeneratedFile>{};

  AFCodeGenerator({
    required this.definitions
  });

  List<String> get pathIdFile { 
    final idFile = "${appNamespace}_id.dart";
    return [libFolder, idFile];
  }

  List<String> get pathAfibConfig {
    return afibConfig;
  }

  String get appNamespace {
    return AFibD.config.appNamespace;
  }

  String get appNamespaceUpper {
    return AFibD.config.appNamespace.toUpperCase();
  }

  List<String> get pathScreenMap { 
    return _createPath(uiPath, screenMapFilename);
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

  List<String>? pathTheme(String themeName) {
    final filename = _namedObjectToFilename(themeName, "Theme");
    if(filename == null) {
      return null;
    }
    return _createPath(themesPath, filename);
    
  }

  List<String> pathScreenTest(String screenName, AFUIControlSettings control) {
    final filename = "${convertMixedToSnake(screenName)}_tests.dart";
    return _createPath(control.prototypesPath, filename);
  }

  List<String> get pathScreenTests {
    return _createPath(testPath, uiPrototypesFilename);
  }

  String get stateViewFullLoginID {
    return "stateViewFullLogin";
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

  List<String> get pathFlutterExportsFile {
    final filename = "${AFibD.config.appNamespace}_flutter.dart";
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
    return AFProjectPaths.projectFileExists(projectPath);
  }

  String importStatementPath(List<String> projectPath) {
    return importPathStatementStatic(projectPath);
  }

   bool addImportsForPath(AFCommandContext ctx, List<String> projectPath, { required List<String> imports }) {
    if(fileExists(projectPath)) {
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


  void addExportsForFiles(AFCommandContext context, Map<String, dynamic> args, List<AFGeneratedFile> files) {
    if(args[AFCommand.argPrivate]) {
      return;
    }
    if(!AFibD.config.isLibraryCommand) {
      return;
    }
    
    final pathExports = pathFlutterExportsFile;
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

  List<String> _createPath(List<String> folders, String filename) {
    return AFProjectPaths.createFile(folders, filename);
  }

  List<String> pathState(String stateName) {
    final path = List<String>.from(statePath);
    path.add(stateName);
    return path;
  }

  void finalizeAndWriteFiles(AFCommandContext context) {
    for(final generatedFile in created.values) {
      generatedFile.executeStandardReplacements(context);
      generatedFile.writeIfModified(context);
    }

    for(final modifiedFile in modified.values) {
      modifiedFile.writeIfModified(context);
    }
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

    if(action == AFGeneratedFileAction.create && AFProjectPaths.projectFileExists(projectPath)) {
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

  AFGeneratedFile loadFile(AFCommandContext context, List<String> path) {
    final key = path.join('/');
    final current = modified[key];
    if(current != null) {
      return current;
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

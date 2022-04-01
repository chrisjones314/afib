import 'package:afib/id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_generated_file.dart';
import 'package:afib/src/dart/command/templates/statements/import_statements.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFCodeGenerator { 
  static const idFile = "id.dart";
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
  static const stateViewsFolder = "stateViews";
  static const screensPath = [libFolder, uiFolder, screensFolder];
  static const modelsPath = [libFolder, stateFolder, modelsFolder];
  static const statePath = [libFolder, stateFolder];
  static const queryPath = [libFolder, queryFolder];
  static const libPath = [libFolder];
  static const uiPath = [libFolder, uiFolder];
  static const afibConfig = [libFolder, initializationFolder, afibConfigFile];
  static const stateViewsPath = [libFolder, uiFolder, stateViewsFolder];
  static const themesPath = [libFolder, uiFolder, themesFolder];

  final AFCommandExtensionContext definitions;
  final created = <String, AFGeneratedFile>{};
  final modified = <String, AFGeneratedFile>{};

  AFCodeGenerator({
    required this.definitions
  });

  List<String> get idFilePath { 
    return [libFolder, idFile];
  }

  List<String> get afibConfigPath {
    return afibConfig;
  }

  List<String> pathScreen(String screenName) {
    final filename = "${convertMixedToSnake(screenName)}.dart";
    return _createPath(screensPath, filename);
  }

  List<String> pathModel(String modelName) {
    final filename = "${convertMixedToSnake(modelName)}.dart";
    return _createPath(modelsPath, filename);
  }

  List<String> pathQuery(String modelName) {
    final filename = "${convertMixedToSnake(modelName)}_query.dart";
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

  AFGeneratedFile loadFile(AFCommandContext context, List<String> path) {
    final result = AFGeneratedFile.fromPath(projectPath: path);
    modified[path.join('/')] = result;
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

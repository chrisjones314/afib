
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_generated_file.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/command/af_command.dart';

class AFCodeGenerator { 
  static const idFile = "id.dart";
  static const afibConfigFile = "afib.g.dart";
  static const libFolder = "lib";
  static const uiFolder = "ui";
  static const initializationFolder = "initialization";
  static const screensFolder = "screens";
  static const stateFolder = "state";
  static const screensPath = [libFolder, uiFolder, screensFolder];
  static const statePath = [libFolder, stateFolder];
  static const afibConfig = [libFolder, initializationFolder, afibConfigFile];
  static const idPath = [libFolder, idFile];

  final AFCommandExtensionContext definitions;
  final created = <String, AFGeneratedFile>{};
  final modified = <String, AFGeneratedFile>{};

  AFCodeGenerator({
    @required this.definitions
  });

  List<String> get idFilePath { 
    return idPath;
  }

  List<String> get afibConfigPath {
    return afibConfig;
  }

  List<String> pathScreen(String screenName) {
    final filename = "${convertMixedToSnake(screenName)}_screen.dart";
    final path = List<String>.from(screensPath);
    path.add(filename);
    return path;
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

  AFGeneratedFile overwriteFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId) {
    return _existingFile(context, projectPath, templateOrId, AFGeneratedFileAction.overwrite);    
  }

  AFGeneratedFile createFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId) {    
    return _existingFile(context, projectPath, templateOrId, AFGeneratedFileAction.create);
  }

  AFGeneratedFile _existingFile(AFCommandContext context, List<String> projectPath, dynamic templateOrId, AFGeneratedFileAction action) {
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
      throw AFCommandError("File at $projectPath needs to be created, but already exists, delete or move it if you'd like to re-create it.");
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

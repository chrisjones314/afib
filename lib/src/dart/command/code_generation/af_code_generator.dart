
import 'package:afib/src/dart/command/af_project_paths.dart';
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
  static const screensPath = [libFolder, uiFolder, screensFolder];
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

  List<String> createPathScreen(String screenName) {
    final filename = "${toSnakeCase(screenName)}_screen.dart";
    final path = List<String>.from(screensPath);
    path.add(filename);
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

  AFGeneratedFile overwriteFile(AFCommandContext context, List<String> projectPath, dynamic templateId) {
    return _existingFile(context, projectPath, templateId, AFGeneratedFileAction.overwrite);    
  }

  AFGeneratedFile createFile(AFCommandContext context, List<String> projectPath, dynamic templateId) {    
    return _existingFile(context, projectPath, templateId, AFGeneratedFileAction.create);
  }

  AFGeneratedFile _existingFile(AFCommandContext context, List<String> projectPath, dynamic templateId, AFGeneratedFileAction action) {
    // if not, return the contents of the template
    final templates = context.definitions.templates;
    final template = templates.find(templateId);
    if(template == null) {
      throw AFException("Could not find template with id $templateId");
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

  static String toSnakeCase(String convert) {
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

  static String toCapitalFirstLetter(String convert) {
    return "${convert[0].toUpperCase()}${convert.substring(1)}";
  }

}

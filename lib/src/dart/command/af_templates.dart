
import 'dart:io';
import 'package:path/path.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

/// Utility for loading, populating, and writing new dart files from templates included
/// with Afib.
class AFTemplates {
  String templateRoot;
  List<String> projectRoot;
  Map<String, String> commonVars;

  AFTemplates() {
    List<String> pathTemplate = split(Platform.script.toFilePath());

    // remove the afib.dart and the bin.
    pathTemplate.removeLast();
    pathTemplate.removeLast();
    pathTemplate.add("tool");
    pathTemplate.add("templates");
    templateRoot = joinAll(pathTemplate);

    Directory current = Directory.current;  
    projectRoot = split(current.path);

    commonVars = Map<String, String>();
    commonVars["generated_warning_comment"] = "// *** WARNING ***: This file is generated source.\n// Do not modify it as your changes might be overwritten in the future.\n// Use the command afib environment ... instead.";
  }

  void writeEnvironment({String environment}) {
    // load in the path for this file.
    /*
    String srcPath = calculateTemplatePath(AFConfigEntries.environmentKey);
    String dstPath = calculateDestPath(["lib", "config", "environment.g.dart"]);
    final localVars = createVars();
    localVars[AFConfigEntries.environmentKey] = environment;
    instantiateTemplate(srcPath, dstPath, localVars);
    */
  }

  Map<String, String> createVars() {
    Map<String, String> localVars = Map<String, String>();
    return localVars;
  }

  String calculateDestPath(List<String> subpath) {
    List<String> calc = List<String>.from(projectRoot);
    calc.addAll(subpath);
    return joinAll(calc);
  }

  String calculateTemplatePath(String name) {
    String filename = name + ".afib";
    return join(templateRoot, filename);
  }

  bool findProjectFile(List<String> subpath) {
    List<String> temp = List<String>.from(projectRoot);
    temp.addAll(subpath);
    String path = joinAll(temp);
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }

  void instantiateTemplate(String srcPath, String dstPath, Map<String, String> localVars) {
    final fileSrc = File(srcPath);
    var content = fileSrc.readAsStringSync();
    content = replaceTemplateVars(content, localVars);
    content = replaceTemplateVars(content, commonVars);
    final fileDst = File(dstPath);
    fileDst.writeAsStringSync(content);
  }

  String replaceTemplateVars(String contentSrc, Map<String, String> vars) {
    vars.forEach((key, value) { 
      StringBuffer reText = StringBuffer(r'\[\[');
      reText.write(key);
      reText.write(r'\]\]');
      final re = RegExp(reText.toString());
      contentSrc = contentSrc.replaceAll(re, value);
    });
    return contentSrc;   
  }
}
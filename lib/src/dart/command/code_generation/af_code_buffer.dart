import 'dart:convert';
import 'dart:io';
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_generator.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// Used to insert code at a particular point in a file.
class AFCodeBuffer {
  static const startCode = "[!";
  static const endCode = "]";

  final List<String>? projectPath;
  final List<String> lines;
  bool modified;

  AFCodeBuffer({
    required this.projectPath,
    required this.lines,
    required this.modified
  });

  factory AFCodeBuffer.empty() {
    return AFCodeBuffer(projectPath: null, lines: <String>[], modified: false);
  }

  factory AFCodeBuffer.fromPath(List<String> projectPath) {
    if(!AFProjectPaths.projectFileExists(projectPath)) {
       throw AFCommandError(error: "Expected to find file at $projectPath but did not.", usage: "");
    }

    final fullPath = AFProjectPaths.fullPathFor(projectPath);
    final file = File(fullPath);

    final ls = LineSplitter();
    final lines = ls.convert(file.readAsStringSync());    
    return AFCodeBuffer(projectPath: projectPath, lines: lines, modified: false);    
  }

  factory AFCodeBuffer.fromTemplate(AFSourceTemplate template) {
    final ls = LineSplitter();
    final lines = ls.convert(template.template);    
    return AFCodeBuffer(projectPath: null, lines: lines, modified: true);
  }


  void resetText(String text) {
    final ls = LineSplitter();
    final newLines = ls.convert(text);    
    lines.clear();
    lines.addAll(newLines);
    modified = true;
  }    
  /// Replaces the specified id with the content of the specified source
  /// template anywhere in the file.
  /// 
  void replaceTemplate(AFCommandContext context, dynamic id, AFSourceTemplate content) {
    if(content.isComment && !AFibD.config.generateBeginnerComments) {
      replaceText(context, id, "");
      return;
    }

    final idCode = id.toString();
    for(var i = 0; i < lines.length; i++) {
      replaceInLine(context, i, idCode, content.createLinesWithOptions);
    }
  }

  void executeStandardReplacements(AFCommandContext context) {
    replaceText(context, AFUISourceTemplateID.textAppNamespace, AFibD.config.appNamespace);
    replaceText(context, AFUISourceTemplateID.textPackageName, AFibD.config.packageName);
    replaceText(context, AFUISourceTemplateID.textPackagePath, context.generator.packagePath(AFibD.config.packageName));
  }

  void appendLine(String line) {
    lines.add(line);
  }

  void appendEmptyLine() {
    modified = true;
    lines.add('');
  }

  void addLinesAfter(AFCommandContext context, RegExp match, List<String> toInsert) {
    modified = true;
    for(var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if(line.contains(match)) {
        lines.insertAll(i+1, toInsert);
        return;
      }
    }
    _throwMissingMatchRegex(match);    
  }

  void addLinesAtEnd(AFCommandContext context, List<String> toInsert) {
    modified = true;
    lines.addAll(toInsert);
  }

  void addLinesBefore(AFCommandContext context, RegExp match, List<String> toInsert) {
    modified = true;
    for(var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if(line.contains(match)) {
        lines.insertAll(i-1, toInsert);
        return;
      }
    }
    _throwMissingMatchRegex(match);
  }

  void _throwMissingMatchRegex(RegExp match) {
    final location = projectPath == null ? "template" : projectPath?.join('/');
    throw AFCommandError(error: "Could not find regular expression $match in $location");
  }

  void replaceTextLines(AFCommandContext context, dynamic id, List<String> lines) {
    final value = StringBuffer();
    for(final line in lines) {
      value.write(line);
      value.write("\n");
    }
    return replaceText(context, id, value.toString());
  }

  /// Replaces the specified id with the specified text value anywhere in the file.
  /// 
  /// The id can be an [AFSourceTemplateID], or it can just be a string.  The value
  /// can be any text, but it should not contain a newline.  This function automatically
  /// handles the template parameters lower and upper, for lowercase and uppercase respectively.
  void replaceText(AFCommandContext context, dynamic id, String value) {
    /// go through all lines, looking for the id.
    final idCode = id.toString();
    for(var i = 0; i < lines.length; i++) {
      replaceInLine(context, i, idCode, (ctx, options) {
        if(options.isEmpty) {
          return [value];
        }
        if(options.indexOf("lower") >= 0) {
          return [value.toLowerCase()];
        }
        if(options.indexOf("upper") >= 0) {
          return [value.toUpperCase()];
        }
        if(options.indexOf("snake") >= 0) {
          return [AFCodeGenerator.convertMixedToSnake(value)];
        }
        if(options.indexOf("camel") >= 0) {
          return [AFCodeGenerator.convertToCamelCase(value)];
        }
        if(options.indexOf("spaces") >= 0) {
          return [AFCodeGenerator.convertMixedToSpaces(value)];
        }

        throw AFCommandError(error: "Unknown option '$options' in tag $idCode");
      });
    }
  }

  void replaceAllWithOptions(AFCommandContext context, dynamic id, List<String> Function(AFCommandContext context, List<String> options) createValue) {
    final idCode = id.toString();
    for(var i = 0; i < lines.length; i++) {
      replaceInLine(context, i, idCode, createValue);
    }
  }


  void replaceInLine(AFCommandContext context, int lineIdx, String code, List<String> Function(AFCommandContext context, List<String> options) createValue) {
    modified = true;
    final lineStart = lines[lineIdx];
    final codeStart = "$startCode$code";
    var curStart = lineStart.lastIndexOf(codeStart);
    while(curStart >= 0) {
      final charNext = lineStart[curStart+codeStart.length];
      if(charNext != "]" && charNext != "(") {
        curStart = lines[lineIdx].lastIndexOf(codeStart, curStart-1);
        continue;
      }
      final lineCur = lines[lineIdx];
      var curEnd = lineCur.indexOf(endCode, curStart);
      if(curEnd < 0) {
        throw AFCommandError(error: "Found $codeStart but failed to find matching $endCode");
      }
      final idxOpenOptions = lineCur.lastIndexOf("(", curEnd);
      final idxCloseOptions = lineCur.lastIndexOf(")", curEnd);
      if(idxOpenOptions > curStart && idxCloseOptions < idxOpenOptions) {
        throw AFCommandError(error: "Found open paren after $codeStart, but did not find close paren.");
      }
      final options = <String>[];
      if(idxOpenOptions > curStart) {
        final optionsStr = lineCur.substring(idxOpenOptions+1, idxCloseOptions);
        final optionsList = optionsStr.split(",");
        options.addAll(optionsList);
      }

      final value = createValue(context, options);
      if(value.length == 1) {
        lines[lineIdx] = lineCur.replaceRange(curStart, curEnd+1, value[0]);
      } else {
        lines.removeAt(lineIdx);
        lines.insertAll(lineIdx, value);
      }
      
      curStart = lines[lineIdx].lastIndexOf(codeStart);
    }
  }

  String toString() {
    return lines.join("\n");
  }

}
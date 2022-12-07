import 'dart:convert';
import 'dart:io';
import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_generator.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
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


  static String quoteIfNonNull(String? value) {
    var result = "null";
    if(value != null) {
      result = '"$value"';
    }
    return result;
  }

  factory AFCodeBuffer.empty() {
    return AFCodeBuffer(projectPath: null, lines: <String>[], modified: false);
  }

  factory AFCodeBuffer.fromPath(List<String> projectPath) {
    if(!AFProjectPaths.projectFileExists(projectPath)) {
       throw AFCommandError(error: "Expected to find file at $projectPath but did not.", usage: "");
    }

    final fullPath = AFProjectPaths.fullPathFor(projectPath);
    return AFCodeBuffer.fromFullPath(projectPath, fullPath);
  }

  factory AFCodeBuffer.fromGeneratePath(List<String> projectPath) {
    if(!AFProjectPaths.generateFileExists(projectPath)) {
       throw AFCommandError(error: "Expected to find file at $projectPath but did not.", usage: "");
    }

    final fullPath = AFProjectPaths.generatePathFor(projectPath);
    return AFCodeBuffer.fromFullPath(projectPath, fullPath);
  }

  factory AFCodeBuffer.fromFullPath(List<String> projectPath, String fullPath) {
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

  String? findFirstAFTag() {
    for(final line in lines) {
      if(line.contains(AFCodeRegExp.afTag)) {
        return line;
      }
    }
    return null;
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

  bool containsInsertionPoint(String insertionPoint) {
    for(final line in lines) {
      if(line.contains(insertionPoint)) {
        return true;
      }
    }
    return false;
  }

  void performInsertions(AFCommandContext context, AFSourceTemplateInsertions insertions) {
    // first, insert all the source templates.
    for(final key in insertions.keys) {
      final value = insertions.valueFor(key);
      final insertion = key.insertionPoint;
      if (value is AFSourceTemplate) {
        if(containsInsertionPoint(insertion)) {
          final buffer = value.toBuffer(context);
          buffer.performInsertions(context, insertions);
          replaceTextLines(context, insertion, buffer.lines);
        }
      } else if(value is AFCodeBuffer) {
          replaceTextLines(context, insertion, value.lines);
      }
    }

    // then, insert all the text strings
    for(final key in insertions.keys) {
      final value = insertions.valueFor(key);
      final insertion = key.insertionPoint;
      if(value is String) {
        replaceText(context, insertion, value);
      }
    }
  }
  
  void appendLine(String line) {
    lines.add(line);
  }

  void appendLineEmpty() {
    modified = true;
    lines.add('');
  }

  int firstLineContaining(AFCommandContext context, RegExp match) {
    for(var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if(line.contains(match)) {
        return i;
      }
    }
    return -1;
  }

  void addLinesAfter(AFCommandContext context, RegExp match, List<String> toInsert) {
    modified = true;
    final idx = firstLineContaining(context, match);
    if(idx < 0) {
      _throwMissingMatchRegex(match);    
    } else {
      lines.insertAll(idx+1, toInsert);
    }    
  }

  void addLinesAfterIdx(AFCommandContext context, int idx, List<String> toInsert) {
    lines.insertAll(idx+1, toInsert);
  }

  void addLinesAtEnd(AFCommandContext context, List<String> toInsert) {
    modified = true;
    lines.addAll(toInsert);
  }

  void addLinesBefore(AFCommandContext context, RegExp match, List<String> toInsert) {
    modified = true;
    final idx = firstLineContaining(context, match);
    if(idx < 0) {
      _throwMissingMatchRegex(match);
    } else {
      lines.insertAll(idx-1, toInsert);
    }    
  }

  void addLineBeforeIndex(AFCommandContext context, int idx, String line) {
    lines.insert(idx, line);
  }

  void _throwMissingMatchRegex(RegExp match) {
    final location = projectPath == null ? "template" : projectPath?.join('/');
    throw AFCommandError(error: "Could not find regular expression $match in $location");
  }

  void replaceTextLines(AFCommandContext context, dynamic id, List<String> linesIn) {
    /// go through all lines, looking for the id.
    final idCode = id.toString();
    for(var i = 0; i < lines.length; i++) {
      replaceInLine(context, i, idCode, (ctx, options) {
        return linesIn;
      });
    }


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
        var result = value;
        if(result.contains("\n")) {
          final lines = result.split("\n");
          return lines;
        }
        if(options.isEmpty) {

        }
        else if(options.indexOf(AFSourceTemplateInsertion.optionLower) >= 0) {
          result = value.toLowerCase();
        }
        else if(options.indexOf(AFSourceTemplateInsertion.optionUpper) >= 0) {
          result = value.toUpperCase();
        }
        else if(options.indexOf(AFSourceTemplateInsertion.optionSnake) >= 0) {
          result = AFCodeGenerator.convertMixedToSnake(value);
        }
        else if(options.indexOf(AFSourceTemplateInsertion.optionCamel) >= 0) {
          result = AFCodeGenerator.convertToCamelCase(value);
        }
        else if(options.indexOf(AFSourceTemplateInsertion.optionSpaces) >= 0) {
          result = AFCodeGenerator.convertMixedToSpaces(value);
        } else {
          throw AFCommandError(error: "Unknown option '$options' in tag $idCode");
        }

        return ["$result"];
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
      final lineCur = lines[lineIdx];
      final charNext = lineCur[curStart+codeStart.length];
      if(charNext != "]" && charNext != "(") {
        if(curStart > 0) {
          curStart = lineCur.lastIndexOf(codeStart, curStart-1);
        } else {
          curStart = -1;
        }
        continue;
      }
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

      // new algorithm.
      // a: Find the indent always.
      final indentBuf = StringBuffer();
      var idxIndent = 0;
      while(idxIndent < lineStart.length) {
        final val = lineStart[idxIndent++];
        if(val.trim().isEmpty) {
          indentBuf.write(val);
        } else {
          break;
        }
      }

      final indent = indentBuf.toString();
      final textBefore = lineCur.substring(idxIndent-1, curStart);
      final textAfter = lineCur.substring(curEnd+1);
      final isSingleLineInsert = textBefore.isNotEmpty && textAfter.isNotEmpty;
      var internalIndent = "";
      if(isSingleLineInsert) {
        internalIndent = "  ";
      }

      // b, this no longer does the indentation
      final value = createValue(context, options);
      final insertLines = <String>[];
      if(value.isEmpty) {
        insertLines.add("$indent$textBefore$textAfter");
      }
      for(var i = 0; i < value.length; i++) {
        final lineInsert = value[i];
        if(i == 0) {
          var suffix = "";
          if(value.length == 1) {
            suffix = textAfter;
          }
          insertLines.add("$indent$textBefore$lineInsert$suffix");
        } else if(i == (value.length - 1)) {
          insertLines.add("$indent$lineInsert$textAfter");
        } else {
          insertLines.add("$indent$internalIndent$lineInsert");
        }
      }
      
      lines.removeAt(lineIdx);
      lines.insertAll(lineIdx, insertLines);
      
      curStart = lineIdx < lines.length ? lines[lineIdx].lastIndexOf(codeStart) : -1;
    }
  }

  String toString() {
    return lines.join("\n");
  }

}
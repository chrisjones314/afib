import 'dart:convert';
import 'dart:io';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_generator.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// An in-memory buffer containing code, used during code generation.
class AFCodeBuffer {
  static const startCode = "[!";
  static const endCode = "]";

  final List<String>? projectPath;
  final List<String> lines;
  final List<String> extraImports;
  bool modified;

  AFCodeBuffer({
    required this.projectPath,
    required this.lines,
    required this.modified,
    required this.extraImports,

  });

  /// Enclosed the specified value in quotes unless it is null.
  static String quoteIfNonNull(String? value) {
    var result = "null";
    if(value != null) {
      result = '"$value"';
    }
    return result;
  }

  factory AFCodeBuffer.empty() {
    return AFCodeBuffer(projectPath: null, lines: <String>[], modified: false, extraImports: <String>[]);
  }

  /// Returns a code buffer containing the contents of the file
  /// 
  /// [projectPath] is relative to the project root.
  factory AFCodeBuffer.fromPath(List<String> projectPath) {
    if(!AFProjectPaths.projectFileExists(projectPath)) {
       throw AFCommandError(error: "Expected to find file at $projectPath but did not.", usage: "");
    }

    final fullPath = AFProjectPaths.fullPathFor(projectPath);
    return AFCodeBuffer.fromFullPath(projectPath, fullPath);
  }

  /// Returns a code buffer containing contents of a file under the project's 'generate' subfolder.
  /// 
  /// The generate folder can contain code generation template overrides, exported using the --export-templates
  /// flag on any generate command.
  factory AFCodeBuffer.fromGeneratePath(List<String> projectPath) {
    if(!AFProjectPaths.generateFileExists(projectPath)) {
       throw AFCommandError(error: "Expected to find file at $projectPath but did not.", usage: "");
    }

    final fullPath = AFProjectPaths.generatePathFor(projectPath);
    return AFCodeBuffer.fromFullPath(projectPath, fullPath);
  }

  /// Returns a code buffer containing the contents of [fullPath]
  /// 
  /// [projectPath] is still saved as a member variable onthe returned buffer.
  factory AFCodeBuffer.fromFullPath(List<String> projectPath, String fullPath) {
    final file = File(fullPath);

    final ls = LineSplitter();
    final lines = ls.convert(file.readAsStringSync());    
    return AFCodeBuffer(projectPath: projectPath, lines: lines, modified: false, extraImports: <String>[]);    
  }


  /// Returns a code buffer created from the specified source template.
  factory AFCodeBuffer.fromTemplate(AFSourceTemplate template) {
    final ls = LineSplitter();
    final lines = ls.convert(template.template);    
    final extraImports = template.extraImports;
    return AFCodeBuffer(projectPath: null, lines: lines, modified: true, extraImports: extraImports);
  }

  /// Returns the first line containing a [AFSourceTemplateInsertion] tag
  String? findFirstAFTag() {
    for(final line in lines) {
      if(line.contains(AFCodeRegExp.afTag)) {
        return line;
      }
    }
    return null;
  }

  /// Replaces the line at the specified index.
  void replaceLine(AFCommandContext context, int idx, String value) {
    lines[idx] = value;
  }

  /// Replaces the entire content of this file with the specified text.
  void resetText(String text) {
    final ls = LineSplitter();
    final newLines = ls.convert(text);    
    lines.clear();
    lines.addAll(newLines);
    modified = true;
  }    
  /// Replaces the specified id with the content of the specified source
  /// template anywhere in the file.
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

  /// Returns true if a line in the file contains the specified [insertionPoint]
  bool containsInsertionPoint(String insertionPoint) {
    for(final line in lines) {
      if(line.contains(insertionPoint)) {
        return true;
      }
    }
    return false;
  }

  /// Sorts imports in the file and removes duplicates
  void fixupImports(String filePath) {
    final allImports = <String>[];

    for(var lineIdx = lines.length - 1; lineIdx >= 0; lineIdx--) {
      final line = lines[lineIdx];
      if(line.startsWith("import ")) {
        final parsedLines = line.split("\n");
        allImports.addAll(parsedLines.where((l) => l.trim().isNotEmpty));
        lines.removeAt(lineIdx);
      }
    }
    
    if(allImports.isEmpty) {
      return;
    }

    allImports.removeWhere((l) => l.trim().isEmpty);
    allImports.sort();

    // remove any duplicate imports.
    for(var i = allImports.length - 1; i >= 1; i--) {
      final cur = allImports[i];
      final prev = allImports[i-1];
      if(prev.trim() == cur.trim()) {
        allImports.removeAt(i);
      }
    }

    allImports.add("");
    lines.insertAll(0, allImports);
  }

  AFCodeBuffer _buildExtraImportsFor(AFCommandContext context, AFSourceTemplateInsertions insertions, Object? value) {
    AFCodeBuffer? buffer;
    if(value == null) {
      buffer = AFCodeBuffer.empty();
    } else if(value is AFSourceTemplate) {
      buffer = value.toBuffer(context);
    } else if(value is AFCodeBuffer) {
      buffer = value;
    } else if(value is String) {
      buffer = AFCodeBuffer.empty();
      buffer.addLinesAtEnd(context, [value]);
    }

    if(buffer == null) {
      throw AFException("Unexpected value type");
    }
    
    for(final insert in insertions.insertions.values) {
      if(insert is AFSourceTemplate) {
        final extra = insert.extraImports;
        if(extra.isNotEmpty) {
          buffer.addLinesAtEnd(context, extra);
        }
      } else if(insert is AFCodeBuffer) {
        final extra = insert.extraImports;
        if(extra.isNotEmpty) {
          buffer.addLinesAtEnd(context, extra);
        }        
      }
    }

    return buffer;
  }

  /// Converts [AFSourceTemplateInsertion] tags into the values specified in [insertions].
  void performInsertions(AFCommandContext context, AFSourceTemplateInsertions insertions) {
    // first, insert all the source templates.
    for(final key in insertions.keys) {
      var value = insertions.valueFor(key);
      if(key == AFSourceTemplate.insertExtraImportsInsertion) {
        value = _buildExtraImportsFor(context, insertions, value);
      }

      final insertion = key.insertionPoint;
      if (value is AFSourceTemplate) {
        if(containsInsertionPoint(insertion)) {
          final buffer = value.toBuffer(context);
          buffer.performInsertions(context, insertions);
          replaceTextLines(context, insertion, buffer.lines);
        }
      } else if(value is AFCodeBuffer) {
        replaceTextLines(context, insertion, value.lines);
      } else if(value is List<String>) {
        replaceTextLines(context, insertion, value);
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
  
  /// Adds the specified line at the end of the file.
  void appendLine(String line) {
    lines.add(line);
  }

  /// Adds an empty line at the end of the file.
  void appendLineEmpty() {
    modified = true;
    lines.add('');
  }

  /// Returns the index of the first line containing [match] in the file.
  /// 
  /// Optionally starts at line [startAt]
  int firstLineContaining(AFCommandContext context, RegExp match, { int startAt = 0 }) {
    for(var i = startAt; i < lines.length; i++) {
      final line = lines[i];
      if(line.contains(match)) {
        return i;
      }
    }
    return -1;
  }

  /// Adds a sete of lines after the first line containing [match]
  void addLinesAfter(AFCommandContext context, RegExp match, List<String> toInsert) {
    modified = true;
    final idx = firstLineContaining(context, match);
    if(idx < 0) {
      _throwMissingMatchRegex(match);    
    } else {
      lines.insertAll(idx+1, toInsert);
    }    
  }

  /// Adds a set of line after the specified index.
  void addLinesAfterIdx(AFCommandContext context, int idx, List<String> toInsert) {
    lines.insertAll(idx+1, toInsert);
  }

  /// Adds a set of line before the specified index.
  void addLinesBeforeIdx(AFCommandContext context, int idx, List<String> toInsert) {
    lines.insertAll(idx, toInsert);
  }

  /// Adds a set of lines at the end of the file.
  void addLinesAtEnd(AFCommandContext context, List<String> toInsert) {
    modified = true;
    lines.addAll(toInsert);
  }

  /// Adds a set of linies before the first line containing [match].
  void addLinesBefore(AFCommandContext context, RegExp match, List<String> toInsert) {
    modified = true;
    final idx = firstLineContaining(context, match);
    if(idx < 0) {
      _throwMissingMatchRegex(match);
    } else {
      lines.insertAll(idx-1, toInsert);
    }    
  }

  /// Adds a single line before the specified index.
  void addLineBeforeIndex(AFCommandContext context, int idx, String line) {
    lines.insert(idx, line);
  }

  void _throwMissingMatchRegex(RegExp match) {
    final location = projectPath == null ? "template" : projectPath?.join('/');
    throw AFCommandError(error: "Could not find regular expression $match in $location");
  }

  /// Replaces all instances of [id] in the file with [linesIn]
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
  /// The id can be an [AFSourceTemplateInsertion], or it can just be a string.  The value
  /// can be any text, but it should not contain a newline.  This function automatically
  /// handles the template parameters modifiers like lower and upper.
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
        } else if(options.indexOf(AFSourceTemplateInsertion.optionCamelPluralize) >= 0) {
          result = AFCodeGenerator.convertToCamelCase(value);
          result = AFCodeGenerator.pluralize(result);
        } else if(options.indexOf(AFSourceTemplateInsertion.optionUpperFirst) >= 0) {
          result = AFCodeGenerator.convertUpcaseFirst(result);
        } else {
          throw AFCommandError(error: "Unknown option '$options' in tag $idCode");
        }

        return ["$result"];
      });
    }
  }

  /// Replaces all the instances of [id] with the lines returned by [createValue].
  void replaceAllWithOptions(AFCommandContext context, dynamic id, List<String> Function(AFCommandContext context, List<String> options) createValue) {
    final idCode = id.toString();
    for(var i = 0; i < lines.length; i++) {
      replaceInLine(context, i, idCode, createValue);
    }
  }

  /// Replaces all instances of [code] in the line with the lines returned by [createValue]
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

  void removeLineAt(int idx) {
    lines.removeAt(idx);
  }

  String toString() {
    return lines.join("\n");
  }

}
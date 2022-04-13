import 'dart:io';

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';
import 'package:afib/src/dart/command/code_generation/af_code_generator.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:colorize/colorize.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

enum AFGeneratedFileAction {
  create,
  modify,
  overwrite
}

/// A file that is in the process of being generated or modified.
class AFGeneratedFile {
  ///
  final List<String> projectPath;
  final AFGeneratedFileAction action;
  AFCodeBuffer buffer;

  AFGeneratedFile({
    required this.projectPath, 
    required this.buffer,
    required this.action,
  });

  factory AFGeneratedFile.fromTemplate({
    required List<String> projectPath,
    required AFSourceTemplate template,
    required AFGeneratedFileAction action
  }) {
    return AFGeneratedFile(
      projectPath: projectPath,
      action: action,
      buffer: template.toBuffer()
    );
  }

  factory AFGeneratedFile.fromPath({
    required List<String> projectPath,
  }) {
    final buffer = AFCodeBuffer.fromPath(projectPath);
    return AFGeneratedFile(
      projectPath: projectPath,
      buffer: buffer,
      action: AFGeneratedFileAction.modify
    );
  }

  String get importPathStatement {
    return AFCodeGenerator.importPathStatementStatic(projectPath);
  }

  Pubspec loadPubspec() {
    return Pubspec.parse(buffer.toString());
  }

  void executeStandardReplacements(AFCommandContext context) {
    buffer.executeStandardReplacements(context);
  }

  void addLinesBefore(AFCommandContext context, RegExp match, List<String> lines, {
    bool preventDuplicates = true
  }) {
    if(!preventDuplicates || !isDuplicateDeclaration(context, lines)) {
      buffer.addLinesBefore(context, match, lines);
    }
  }

  void addLinesAfter(AFCommandContext context, RegExp match, List<String> lines, {
    bool preventDuplicates = true
  }) {
    if(!preventDuplicates || !isDuplicateDeclaration(context, lines)) {  
      buffer.addLinesAfter(context, match, lines);
    }
  }

  void addLinesAtEnd(AFCommandContext context, List<String> lines, {
    bool preventDuplicates = true
  }) {
    if(!preventDuplicates || !isDuplicateDeclaration(context, lines)) {
      buffer.addLinesAtEnd(context, lines);
    }
  }

  bool isDuplicateDeclaration(AFCommandContext context, List<String> lines) {
    if(lines.isEmpty) {
      throw AFException("Expected at least one line, found $lines");
    }

    // just checking the first line works for both function and id declarations
    final line = lines.first;
    for(final lineTest in buffer.lines) {
      if(lineTest.contains(line)) {
        return true;
      }
    }    
    return false;
  }

  /// Resolves references to other registered templates.
  void resolveTemplateReferences({
    required AFCommandContext context, 
  }) {
    final templates = context.definitions.templates;
    for(final id in templates.templateCodes) {
      final template = templates.find(id);
      assert(template != null);
      if(template != null) {
        if(template.isComment && !AFibD.config.generateBeginnerComments) {
          buffer.replaceText(context, id, "");
        } else {
          buffer.replaceTemplate(context, id.toString(), template);
        }
      }
    }
  }

  /// Replaces all instances of the specified id with 
  /// the specified value.
  /// 
  /// Handles the standard parameters upper and lower.
  void replaceText(AFCommandContext context, dynamic id, String value) {
    return buffer.replaceText(context, id, value);
  }

  void replaceTextLines(AFCommandContext context, dynamic id, List<String> lines) {
    final value = StringBuffer();
    for(final line in lines) {
      value.write(line);
      value.write("\n");
    }
    return buffer.replaceText(context, id, value.toString());
  }

  void replaceTextTemplate(AFCommandContext context, dynamic id, AFSourceTemplate? template) {
    if(template == null) {
      buffer.replaceText(context, id, "");
    } else {
      replaceTextLines(context, id, template.toBuffer().lines);
    }
  }

  /// Replaces all instances of the specified id with the value
  /// returned by the template.
  /// 
  /// Note that you can use this function, combined with a [AFDynamicSourceTemplate] subclass,
  /// in order to insert dynamically generated sections of code in an existing template.
  void replaceTemplate(AFCommandContext context, dynamic id, AFSourceTemplate template) {
    return buffer.replaceTemplate(context, id, template);
  }

  void writeIfModified(AFCommandContext context) {
    write(context);
  }

  void write(AFCommandContext context) {
    final output = context.output;
    // make sure the folder exists before we write a file.
    AFProjectPaths.ensureFolderExistsForFile(projectPath);

    _writeAction(output);
    output.startColumn(
      alignment: AFOutputAlignment.alignLeft
    );
    output.write(AFProjectPaths.relativePathFor(projectPath));
    output.endLine();

    final path = AFProjectPaths.fullPathFor(this.projectPath);
    final f = File(path);
    f.writeAsStringSync(buffer.toString());
  }

  void _writeAction(AFCommandOutput output) {
    final color = (action == AFGeneratedFileAction.create) ? Styles.GREEN : Styles.YELLOW;
    output.startColumn(
      alignment: AFOutputAlignment.alignRight,
      width: 15,
      color: color);
    var text = "create";
    if(action == AFGeneratedFileAction.modify) {
      if(!buffer.modified) {
        text = "skip";
      } else {
        text = "modify";
      }
    } else if(action == AFGeneratedFileAction.overwrite) {
      text = "overwrite";
    }
    
    output.write("$text ");
  }
}

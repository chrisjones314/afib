import 'dart:io';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:colorize/colorize.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';

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

  void executeStandardReplacements(AFCommandContext context) {
    buffer.executeStandardReplacements(context);
  }


  void addLinesAfter(AFCommandContext context, RegExp match, List<String> lines) {
    buffer.addLinesAfter(context, match, lines);
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
        buffer.replaceTemplate(context, id.toString(), template);
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

  /// Replaces all instances of the specified id with the value
  /// returned by the template.
  /// 
  /// Note that you can use this function, combined with a [AFDynamicSourceTemplate] subclass,
  /// in order to insert dynamically generated sections of code in an existing template.
  void replaceTemplate(AFCommandContext context, dynamic id, AFSourceTemplate template) {
    return buffer.replaceTemplate(context, id, template);
  }

  void writeIfModified(AFCommandContext context) {
    if(buffer.modified) {
      write(context);
    }
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
      text = "modify";
    } else if(action == AFGeneratedFileAction.overwrite) {
      text = "overwrite";
    }
    output.write("$text ");
  }
}

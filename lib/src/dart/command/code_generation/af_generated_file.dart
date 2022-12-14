import 'dart:io';

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';
import 'package:afib/src/dart/command/code_generation/af_code_generator.dart';
import 'package:afib/src/dart/command/templates/af_code_regexp.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_import_from_package.t.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:colorize/colorize.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

enum AFGeneratedFileAction {
  create,
  modify,
  overwrite,
  skip,
  projectStyle,
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

  factory AFGeneratedFile.fromBuffer({
    required List<String> projectPath,
    required AFCodeBuffer buffer,
    required AFGeneratedFileAction action
  }) {
    return AFGeneratedFile(
      projectPath: projectPath,
      action: action,
      buffer: buffer
    );

  }

  factory AFGeneratedFile.fromTemplate({
    required AFCommandContext context,
    required List<String> projectPath,
    required AFSourceTemplate template,
    required AFGeneratedFileAction action
  }) {

    // see if an override exists, if it does, use it.
    var effective = template.toBuffer(context);
    var effectivePath = projectPath;
    if(template is AFFileSourceTemplate) {
      final originalPath = template.templatePath;

      // this is the command-line override, which switches the template path dynamically.
      final overridePath = context.findOverrideTemplate(originalPath);
      final hasOverride = overridePath != originalPath;
      if(context.isExportTemplates) {
        effectivePath = AFProjectPaths.generateFolderFor(overridePath);
      }

      if(AFProjectPaths.generateFileExists(overridePath)) {
        action = AFGeneratedFileAction.skip;
      }


      // if there is an override for that path on the filesystem, use it.
      if(AFProjectPaths.generateFileExists(overridePath)) {
        effective = AFCodeBuffer.fromGeneratePath(overridePath);
      } else {
        // if the path changed, and the override path is not on the filesystem, see if it 
        // is one of our predefined paths.
        if(hasOverride) {
          final overrideTemplate = context.findEmbeddedTemplateFile(overridePath);
          if(overrideTemplate == null) {
            throw AFException("The override ${joinAll(overridePath)} was not found on the file system, or in the AFTemplateRegistry, for ${joinAll(originalPath)}");
          }
          effective = overrideTemplate.toBuffer(context);
        }
      }

    }

    return AFGeneratedFile(
      projectPath: effectivePath,
      action: action,
      buffer: effective,
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

  String? findFirstAFTag() {
    return buffer.findFirstAFTag();
  }

  String get importPathStatement {
    return AFCodeGenerator.importPathStatementStatic(projectPath);
  }

  Pubspec loadPubspec() {
    return Pubspec.parse(buffer.toString());
  }

  void importFile(AFCommandContext context, AFGeneratedFile file, { String? packageName }) {
    importProjectPathString(context, file.importPathStatement, packageName: packageName);
  }

  void importIDFile(AFCommandContext context, AFLibraryID libraryId) {
    importProjectPathString(context, "${libraryId.codeId}_id.dart", packageName: libraryId.name);
  }

  void importFlutterFile(AFCommandContext context, AFLibraryID libraryId) {            
    importProjectPathString(context, "${libraryId.codeId}_flutter.dart", packageName: libraryId.name);
  }

  void importProjectPath(AFCommandContext context, List<String> importPath, { String? packageName }) {
    final path = AFCodeGenerator.importPathStatementStatic(importPath);
    importProjectPathString(context, path, packageName: packageName);
  }
  
  void importProjectPathString(AFCommandContext context, String importPath, { String? packageName }) {
    final declareImport = SnippetImportFromPackageT().toBuffer(context, insertions: {
      AFSourceTemplate.insertPackageNameInsertion: packageName ?? AFibD.config.packageName,
      AFSourceTemplate.insertPackagePathInsertion: importPath,
    });
    importAll(context, declareImport.lines);
  }

  void importAll(AFCommandContext context, List<String> imports, {
    bool preventDuplicates = true
  }) {
    // find the insertion point.
    final lastImportLine = _findLastImportLine();
    var insertOffset = lastImportLine == 0 ? 0 : 1;
    for(final import in imports) {
      if(!preventDuplicates || !isDuplicateDeclaration(context, [import])) {
        buffer.addLineBeforeIndex(context, lastImportLine+insertOffset, import);
        insertOffset++;
      }
    }
  }

  int _findLastImportLine() {
    var idx = 0;
    for(var i = 0; i < buffer.lines.length; i++) {
      final line = buffer.lines[i];
      final foundImport = line.indexOf(AFCodeRegExp.startImportLine);
      if(foundImport == 0) {
        idx = i;
      }
    }
    return idx;
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

  void addLinesAfterIdx(AFCommandContext context, int idx, List<String> lines, {
    bool preventDuplicates = true
  }) {
    if(!preventDuplicates || !isDuplicateDeclaration(context, lines)) {  
      buffer.addLinesAfterIdx(context, idx, lines);
    }
  }

  void addLinesAtEnd(AFCommandContext context, List<String> lines, {
    bool preventDuplicates = true
  }) {
    if(!preventDuplicates || !isDuplicateDeclaration(context, lines)) {
      buffer.addLinesAtEnd(context, lines);
    }
  }

  int firstLineContaining(AFCommandContext context, RegExp match) {
    return buffer.firstLineContaining(context, match);
  }


  bool isDuplicateDeclaration(AFCommandContext context, List<String> lines) {
    if(lines.isEmpty) {
      throw AFException("Expected at least one line, found $lines");
    }

    // just checking the first line works for both function and id declarations
    var firstNonEmpty = lines.firstWhere((element) => element.isNotEmpty);
    
    for(final lineTest in buffer.lines) {
      if(lineTest.contains(firstNonEmpty)) {
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
        buffer.replaceTemplate(context, id.toString(), template);
      }
    }
  }

  void performInsertions(AFCommandContext context, AFSourceTemplateInsertions insertions) {
    buffer.performInsertions(context, insertions);
  }

  /// Replaces all instances of the specified id with 
  /// the specified value.
  /// 
  /// Handles the standard parameters upper and lower.
  void replaceText(AFCommandContext context, dynamic id, String value) {
    return buffer.replaceText(context, id, value);
  }

  void replaceTextLines(AFCommandContext context, dynamic id, List<String> lines) {
    buffer.replaceTextLines(context, id, lines);
  }


  void replaceTextTemplate(AFCommandContext context, dynamic id, AFSourceTemplate? template) {
    if(template == null) {
      buffer.replaceText(context, id, "");
    } else {
      replaceTextLines(context, id, template.toBuffer(context).lines);
    }
  }

  /// Replaces all instances of the specified id with the value
  /// returned by the template.
  /// 
  /// Note that you can use this function, combined with a [AFDynamicSourceTemplate] subclass,
  /// in order to insert dynamically generated sections of code in an existing template.
  void replaceTemplate(AFCommandContext context, dynamic id, AFSourceTemplate? template) {
    if(template == null) {
      buffer.replaceText(context, id, "");
      return;
    }
    return buffer.replaceTemplate(context, id, template);
  }

  void writeIfModified(AFCommandContext context) {
    write(context);
  }

  void write(AFCommandContext context) {
    final output = context.output;
    // make sure the folder exists before we write a file.
    AFProjectPaths.ensureFolderExistsForFile(projectPath);

    _writeAction(context);
    output.startColumn(
      alignment: AFOutputAlignment.alignLeft
    );
    output.write(AFProjectPaths.relativePathFor(projectPath));
    output.endLine();

    final path = AFProjectPaths.fullPathFor(this.projectPath);

    // fix up any imports, sorting them and removing excess spaces.
    buffer.fixupImports();

    final f = File(path);
    f.writeAsStringSync(buffer.toString());
  }

  void _writeAction(AFCommandContext context) {
    final output = context.output;
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
    } else if(action == AFGeneratedFileAction.skip) {
      text = "skip";
    } else if(action == AFGeneratedFileAction.projectStyle) {
      text = context.isExportTemplates ? "create" : "read";
    }
    
    output.write("$text ");
  }
}

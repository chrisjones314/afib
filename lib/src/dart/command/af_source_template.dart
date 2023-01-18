import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';
import 'package:afib/src/dart/command/code_generation/af_generated_file.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_empty_statement.t.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

/// An insertion point in a file, with an optional whitespace indentation before each line.
class AFTemplateReplacementPoint extends AFItemWithNamespace {
  final String indent;
  AFTemplateReplacementPoint(String namespace, String key, this.indent): super(namespace, key);
}

enum AFFileTemplateCreationRule {
  createAlways,
  createOnce,
  updateInPlace
}

enum AFSourceTemplateRole {
  code,
  comment,
}

@immutable 
class AFSourceTemplateInsertion {
  static const optionsNone = "none";
  static const optionUpper = "upper";
  static const optionSnake = "snake";
  static const optionLower = "lower";
  static const optionCamel = "camel";
  static const optionSpaces = "spaces";  

  final String insertion;
  final String options;

  const AFSourceTemplateInsertion(this.insertion, {
    this.options = optionsNone,
  });

  AFSourceTemplateInsertion get lower => AFSourceTemplateInsertion(insertion, options: optionLower);
  AFSourceTemplateInsertion get upper => AFSourceTemplateInsertion(insertion, options: optionUpper);
  AFSourceTemplateInsertion get snake => AFSourceTemplateInsertion(insertion, options: optionSnake);
  AFSourceTemplateInsertion get camel => AFSourceTemplateInsertion(insertion, options: optionCamel);
  AFSourceTemplateInsertion get spaces => AFSourceTemplateInsertion(insertion, options: optionSpaces);
  String get breadcrumb {
    return "//!af_$insertion";
  }

  String get insertionPoint => "af_$insertion";

  String get optionsSuffix {
    if(options == optionsNone) {
      return "";
    }

    return "($options)";
  }

  String toString() {
    return "${AFCodeBuffer.startCode}$insertionPoint$optionsSuffix${AFCodeBuffer.endCode}";
  }

}

@immutable
class AFSourceTemplateInsertions {
  final Map<AFSourceTemplateInsertion, Object> insertions;

  const AFSourceTemplateInsertions({
    required this.insertions,
  });

  bool get isEmpty => insertions.isEmpty;
  bool get isNotEmpty => insertions.isNotEmpty;

  Iterable<AFSourceTemplateInsertion> get keys {
    return insertions.keys;
  }

  Object? valueFor(AFSourceTemplateInsertion key) {
    return insertions[key];
  }

  factory AFSourceTemplateInsertions.createCore({ required String packagePath }) {
    final appNamespace = AFibD.config.appNamespace;
    final appNamespaceUpper = appNamespace.toUpperCase();
    final insertions = <AFSourceTemplateInsertion, Object>{
      AFSourceTemplate.insertAppNamespaceInsertion: appNamespace,
      AFSourceTemplate.insertPackageNameInsertion: AFibD.config.packageName,
      AFSourceTemplate.insertPackagePathInsertion: packagePath,
      AFSourceTemplate.insertStateTypeInsertion: "${appNamespaceUpper}State",
      AFSourceTemplate.insertFileHeaderInsertion: AFibD.config.fileHeader,
    };
    return AFSourceTemplateInsertions(insertions: insertions);
  }

  AFSourceTemplateInsertions reviseAugment(
    Map<AFSourceTemplateInsertion, Object> added
  ) {
    final revised = Map<AFSourceTemplateInsertion, Object>.from(insertions);
    for(final key in added.keys) {
      // in augment, don't replace what is already there.
      if(revised.containsKey(key)) {
        continue;
      }
      final value = added[key];
      if(value == null) {
        continue;
      }
      revised[key] = value;
    }
    return AFSourceTemplateInsertions(insertions: revised);
  }

  AFSourceTemplateInsertions reviseOverwrite(
    Map<AFSourceTemplateInsertion, Object> added
  ) {
    final revised = Map<AFSourceTemplateInsertion, Object>.from(insertions);
    for(final key in added.keys) {
      final value = added[key];
      if(value == null) {
        continue;
      }
      revised[key] = value;
    }
    return AFSourceTemplateInsertions(insertions: revised);
  }

}

/// A source of template source code. 
/// 
/// It would seem more natural to store the templates as text file resources,
/// but because dart programs are sometimes compiled, you cannot depend on
/// resource files to be present (see https://github.com/dart-archive/resource)
abstract class AFSourceTemplate {
  static const insertAppNamespaceInsertion = AFSourceTemplateInsertion("app_namespace");
  static const insertPackageNameInsertion = AFSourceTemplateInsertion("package_name");
  static const insertPackagePathInsertion = AFSourceTemplateInsertion("package_path");
  static const insertStateTypeInsertion = AFSourceTemplateInsertion("state_type");
  static const insertFileHeaderInsertion = AFSourceTemplateInsertion("file_header");
  static const insertAdditionalMethodsInsertion = AFSourceTemplateInsertion("additional_methods");
  static const insertMemberVariablesInsertion = AFSourceTemplateInsertion("member_variables");
  static const insertConstructorParamsInsertion = AFSourceTemplateInsertion("constructor_params");
  static const insertSuperParamsInsertion = AFSourceTemplateInsertion("super_params");
  static const insertExtraImportsInsertion = AFSourceTemplateInsertion("extra_imports");
  static const insertLibKindInsertion = AFSourceTemplateInsertion("lib_kind");
  static const insertMainTypeInsertion = AFSourceTemplateInsertion("main_type");
  static const insertMainParentTypeInsertion = AFSourceTemplateInsertion("main_parent_type");
  static const insertCopyWithParamsInsertion = AFSourceTemplateInsertion("copy_with_params");
  static const insertCopyWithCallInsertion = AFSourceTemplateInsertion("copy_with_constructor_call");
  static const insertCreateParamsInsertion = AFSourceTemplateInsertion("create_params");
  static const insertCreateParamsCallInsertion = AFSourceTemplateInsertion("create_params_call");
  static const insertMainTypeNoRootInsertion = AFSourceTemplateInsertion("main_type_no_root");
  static const insertProjectStyleInsertion = AFSourceTemplateInsertion("project_style");
  static const insertMemberVariableImportsInsertion = AFSourceTemplateInsertion("member_variable_imports");

  static const empty = SnippetEmptyStatementT();
  final AFSourceTemplateRole role;
  final AFSourceTemplateInsertions? embeddedInsertions; 
  
  const AFSourceTemplate({ 
    this.role = AFSourceTemplateRole.code,
    this.embeddedInsertions,
  });

  List<String> get extraImports {
    return <String>[];
  }

  AFSourceTemplateInsertion get insertProjectStyle { return AFSourceTemplate.insertProjectStyleInsertion; }
  AFSourceTemplateInsertion get insertAppNamespace { return AFSourceTemplate.insertAppNamespaceInsertion; }
  AFSourceTemplateInsertion get insertAppNamespaceUpper { return AFSourceTemplate.insertAppNamespaceInsertion.upper; }
  AFSourceTemplateInsertion get insertStateType { return AFSourceTemplate.insertStateTypeInsertion; }
  AFSourceTemplateInsertion get insertPackagePath { return AFSourceTemplate.insertPackagePathInsertion; }
  AFSourceTemplateInsertion get insertPackageName { return AFSourceTemplate.insertPackageNameInsertion; }
  AFSourceTemplateInsertion get insertFileHeader { return AFSourceTemplate.insertFileHeaderInsertion; }
  AFSourceTemplateInsertion get insertConstructorParams { return AFSourceTemplate.insertConstructorParamsInsertion; }
  AFSourceTemplateInsertion get insertMemberVariables { return AFSourceTemplate.insertMemberVariablesInsertion; }
  AFSourceTemplateInsertion get insertAdditionalMethods { return AFSourceTemplate.insertAdditionalMethodsInsertion; }
  AFSourceTemplateInsertion get insertSuperParams { return AFSourceTemplate.insertSuperParamsInsertion; }
  AFSourceTemplateInsertion get insertExtraImports { return AFSourceTemplate.insertExtraImportsInsertion; }
  AFSourceTemplateInsertion get insertLibKind { return AFSourceTemplate.insertLibKindInsertion; }
  AFSourceTemplateInsertion get insertMainType { return AFSourceTemplate.insertMainTypeInsertion; }
  AFSourceTemplateInsertion get insertMainTypeNoRoot { return AFSourceTemplate.insertMainTypeNoRootInsertion; }
  AFSourceTemplateInsertion get insertMainParentType { return AFSourceTemplate.insertMainParentTypeInsertion; }
  AFSourceTemplateInsertion get insertCopyWithParams { return AFSourceTemplate.insertCopyWithParamsInsertion; }
  AFSourceTemplateInsertion get insertCopyWithConstructorCall { return AFSourceTemplate.insertCopyWithCallInsertion; }
  AFSourceTemplateInsertion get insertCreateParams { return AFSourceTemplate.insertCreateParamsInsertion; }
  AFSourceTemplateInsertion get insertCreateParamsCall { return AFSourceTemplate.insertCreateParamsCallInsertion; }
  AFSourceTemplateInsertion get insertMemberVariableImports { return AFSourceTemplate.insertMemberVariableImportsInsertion; }

  bool get isComment { return role == AFSourceTemplateRole.comment; }
  bool get isCode { return role == AFSourceTemplateRole.code; }

  String get template;

  bool containsInsertionPoint(String insertionPoint) {
    return template.contains(insertionPoint);
  }

  AFCodeBuffer toBuffer(AFCommandContext context, { Map<AFSourceTemplateInsertion, Object>? insertions }) {
    var fullInsertions = AFSourceTemplateInsertions(insertions: <AFSourceTemplateInsertion, Object>{});
    if(insertions != null) {
      fullInsertions = fullInsertions.reviseAugment(insertions);
    }
    final ei = embeddedInsertions;
    if(ei != null) {
      fullInsertions = fullInsertions.reviseAugment(ei.insertions);
    }
    final buffer = AFCodeBuffer.fromTemplate(this);
    if(fullInsertions.isNotEmpty) {
      buffer.performInsertions(context, fullInsertions);
    }
    return buffer;
  }

  List<String> createLinesWithOptions(AFCommandContext context, List<String> options) {
    final buffer = toBuffer(context);
    return buffer.lines;
  }

}

abstract class AFPathSourceTemplate extends AFSourceTemplate {

  final List<String> templateFolder;
  final String templateFileId;

  const AFPathSourceTemplate({
    required this.templateFolder,
    required this.templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions, 
  }): super(embeddedInsertions: embeddedInsertions);

  String get templateId => joinAll(templatePath);

  List<String> get templatePath {
    final result = templateFolder.toList();
    result.add(templateFileId);
    return result;
  }
}

abstract class AFSnippetSourceTemplate extends AFPathSourceTemplate {  

  const AFSnippetSourceTemplate({
    required List<String> templateFolder,
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions, 
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );
}

abstract class AFCoreSnippetSourceTemplate extends AFSnippetSourceTemplate {  

  const AFCoreSnippetSourceTemplate({
    String templateFileId = "TODO",
    AFSourceTemplateInsertions? embeddedInsertions, 
  }): super(
    templateFileId: templateFileId,
    templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
    embeddedInsertions: embeddedInsertions
  );
}


abstract class AFFileSourceTemplate extends AFPathSourceTemplate {
  static const templatePathCore = "core";
  static const templatePathExample = "examples";
  
  const AFFileSourceTemplate({
    required List<String> templateFolder,
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions, 
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );


  AFGeneratedFile createGeneratedTemplate(AFCommandContext context) {
    final relativePath = AFProjectPaths.generateFolderFor(templatePath);
    return AFGeneratedFile.fromTemplate(context: context, projectPath: relativePath, template: this, action: AFGeneratedFileAction.create);
  }
}

abstract class AFCoreFileSourceTemplate extends AFFileSourceTemplate {

 const AFCoreFileSourceTemplate({
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions, 
  }): super(
    templateFileId: templateFileId,
    templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    embeddedInsertions: embeddedInsertions,
  );

}


abstract class AFProjectStyleSourceTemplate extends AFFileSourceTemplate {
  const AFProjectStyleSourceTemplate({
    required String templateFileId,
    AFSourceTemplateInsertions? embeddedInsertions, 
  }): super(
    templateFileId: templateFileId,
    templateFolder: AFProjectPaths.pathProjectStyles,
    embeddedInsertions: embeddedInsertions
  );
}

abstract class AFSourceTemplateComment extends AFSourceTemplate {
  AFSourceTemplateComment(): super(role: AFSourceTemplateRole.comment);
}

abstract class AFDynamicSourceTemplate extends AFSourceTemplate {

  final template = "";
  
  @override
  AFCodeBuffer toBuffer(AFCommandContext context, { Map<AFSourceTemplateInsertion, Object>? insertions }) {
    final lines = createLinesWithOptions(context, <String>[]);
    final result = AFCodeBuffer.empty();
    result.addLinesAtEnd(context, lines);
    return result;
  }


  List<String> createLinesWithOptions(AFCommandContext context, List<String> options);
}


import 'dart:io';

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_id_generator_step.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';
import 'package:afib/src/dart/command/generators/af_id_generator.dart';
import 'package:afib/src/dart/command/templates/afib.t.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_template_source.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';
import 'package:afib/src/dart/command/generators/af_config_generator.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_exception.dart';


class AFInsertionPoint {
  final String id;
  AFInsertionPoint(this.id);

  factory AFInsertionPoint.create(String id) {
    return AFInsertionPoint(id);
  }

  String get fullText {
    return buildFullText(id, false);
  }

  String get codeText {
    return buildCodeText(id);
  }

  RegExp get replaceRegexFor {
    final source = StringBuffer();
    source.write("//\\s+");
    source.write(buildFullText(id, true));
    source.write(".*");
    return RegExp(source.toString());
  }

  String findIndentFor(String content) {
    final source = StringBuffer();
    source.write("(\\s*)//\\s+");
    source.write(buildFullText(id, true));
    final re = RegExp(source.toString());
    final matches = re.allMatches(content);
    if(matches.isEmpty) {
      throw AFException("Expected to find pattern $re");
    }
    final first = matches.first;
    return first.group(1);
  }

  static String buildFullText(String id, bool forRegex) {
    final kind = id[0].toUpperCase() + id.substring(1) + "ID";
    final reSource = StringBuffer();
    reSource.write("AFibInsertionPoint");
    reSource.write(forRegex ? "\\(" : "(");
    reSource.write(kind);
    reSource.write(forRegex ? "\\)" : ")");
    return reSource.toString();
  }

  static String buildCodeText(String id) {
    final sb = StringBuffer();
    sb.write("// ");
    sb.write(buildFullText(id, false));
    sb.write(" - Do not Delete.");
    return sb.toString();
  }
}

/// A file that is in the process of being generated or modified.
class AFGeneratedFile {
  ///
  final List<String> projectPath;
  String content;
  bool modified = false;

  AFGeneratedFile(this.projectPath, this.content);

  bool containsInsertionPoint(AFInsertionPoint insert) {
    return content.contains(insert.replaceRegexFor);
  }

  void save(AFCommandOutput output) {
    output.writeLine("Writing ${AFProjectPaths.pathFor(projectPath)}");
    final path = AFProjectPaths.projectPathFor(this.projectPath);
    final f = File(path);
    f.writeAsStringSync(content);
  }

  void appendBeforeInsertionPoint(AFCommandContext ctx, AFInsertionPoint insert, AFCodeGenerator generator) {
    // generate the desired source with the original insertion point already prefixed.
    final buffer = AFCodeBuffer();
    generator.execute(ctx, buffer);
    buffer.writeLine(insert.codeText);

    String indent = insert.findIndentFor(content);
    final re = insert.replaceRegexFor;
    updateContent(content.replaceAll(re, buffer.withIndent(indent))); 
    ctx.output.writeLine("Inserted code in ${AFProjectPaths.pathFor(projectPath)}");
  }

  void updateContent(String revised) {
    this.content = revised;
    modified = true;
  }

}

/// The current state of any files that are being generated or modified during the current
/// generate command.
class AFGeneratedFiles {
  final files = Map<String, AFGeneratedFile>();
  final templates = Map<String, AFTemplateSource>();

  void saveChangedFiles(AFCommandOutput output) {
    for(final file in files.values) {
      if(file.modified) {
        file.save(output);
      }
    }
  }

  bool exists(List<String> projectPath) {
    return AFProjectPaths.projectFileExists(projectPath);
  }

  void registerFile(List<String> projectPath, AFTemplateSource source) {
    final path = AFProjectPaths.pathFor(projectPath);
    templates[path] = source;
  }

  AFGeneratedFile fileFor(List<String> projectPath) {
    final path = AFProjectPaths.pathFor(projectPath);
    var file = files[path];
    if(file == null) {
      /// read in the file.
      final f = File(AFProjectPaths.projectPathFor(projectPath));
      final content = f.readAsStringSync();
      file = AFGeneratedFile(projectPath, content);
      files[path] = file;
    }
    return file;
  }

  AFTemplateSource templateFor(List<String> projectPath) {
    final path = AFProjectPaths.pathFor(projectPath);
    return templates[path];
  }
}

/// A single process in the 
abstract class AFSourceGeneratorStep {

  /// Validate that all the necessary templates, insertion points, and parameters
  /// are valid prior to doing the source code generation.
  /// 
  /// If they are not, output an error and return false.
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files);
}

/// A an algorithm that manipulates one or more pieces of code, consisting
/// of a serious of [AFSourceGeneratorStep]
class AFSourceGenerator extends AFItemWithNamespace {
  final steps = List<AFFileGeneratorStep>();
  final String shortHelp;

  /// 
  AFSourceGenerator(String namespace, String key, this.shortHelp): super(namespace, key);

  void addStep(AFSourceGeneratorStep step) {
    steps.add(step);
  }

  /// Validates that all the steps are valid.
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    for(final step in steps) {
      if(!step.validateBefore(ctx, files)) {
        return false;
      }
    }
    return true;
  }

  void execute(AFCommandContext ctx, AFGeneratedFiles files) {
    for(final step in steps) {
      step.execute(ctx, files);
    }
    
  }

  /// Writes out a single line help statement.
  void writeShortHelp(AFCommandOutput output, {int indent = 0}) {
    AFCommand.startCommandColumn(output, indent: indent);
    output.write(namespaceKey + " - ");
    AFCommand.startHelpColumn(output);
    output.writeLine(shortHelp);
  }

}

/// An extensible command used to generate source code from the command-line.
class AFGenerateCommand extends AFCommand {
  static const cmdKey = "generate";
  final generators = Map<String, AFSourceGenerator>();
  final files = AFGeneratedFiles();

  AFGenerateCommand(): super(AFConfigEntries.afNamespace, cmdKey, 1, 0) {
    files.registerFile(AFProjectPaths.afibConfigPath, AFibT());

    registerGenerator(AFConfigGenerator());
    registerGenerator(AFIDGenerator());
  }

  void registerGenerator(AFSourceGenerator generator) {
    generators[generator.namespaceKey] = generator;
  }

  AFConfigGenerator get configGenerator {
    return generators[AFConfigGenerator.cmdKey];
  }

  @override
  void execute(AFCommandContext ctx) {
    final genKey = ctx.args.at(0);
    final generator = generators[genKey];
    if(generator == null) {
      ctx.output.writeErrorLine("Unknown generator $genKey, stopping.");
      return;
    }

    if(!generator.validateBefore(ctx, files)) {
      return;
    }

    generator.execute(ctx, files);


    files.saveChangedFiles(ctx.output);
  }

  @override
  String get shortHelp {
    return "Generate source code elements such as screens, queries, and identifiers";
  }

  @override  
  void writeLongHelp(AFCommandOutput output, String subCommand) {
    writeShortHelp(output);
    if(subCommand == null) {
      AFCommand.emptyCommandColumn(output);
      AFCommand.startHelpColumn(output);
      output.writeLine("Use help generate <generator> for any of the following generators:");
      final gens = List<AFSourceGenerator>.of(generators.values);
      gens.sort( (l, r) { return l.namespaceKey.compareTo(r.namespaceKey); });
      for(final gen in gens) {
        gen.writeShortHelp(output, indent: 1);
      }
    }
  }
}
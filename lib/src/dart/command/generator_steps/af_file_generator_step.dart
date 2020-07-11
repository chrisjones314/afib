
import 'dart:io';

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_template_source.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';
import 'package:afib/src/dart/utils/af_exception.dart';

/// A step that generates an entire file, which can contain expandable
/// code segments within it.
class AFFileGeneratorStep extends AFSourceGeneratorStep {
  final List<String> projectPath;
  final sections = Map<String, AFCodeGenerator>();

  AFFileGeneratorStep(this.projectPath);

  /// Set a handler for a dynamic section (e.g. [!insert_code_here!] in the template)
  void setCodeGenerator(AFCodeGenerator step) {
    sections[step.key] = step;
  }

  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    final output = ctx.output;
    final template = files.templateFor(this.projectPath);
    List<AFTemplateReplacementPoint> points = template.findReplacementPoints();
    for(final point in points) {
      if(!sections.containsKey(point.key)) {
        output.writeErrorLine("Missing dynamic section handler ${point.key} while generating ${projectPath}");
        return false;
      }
    }
    return true;
  }

  void execute(AFCommandContext ctx, AFGeneratedFiles files) {
    final template = files.templateFor(this.projectPath);
    List<AFTemplateReplacementPoint> points = template.findReplacementPoints();
    final start = StringBuffer();
    start.writeln("// File last generated at ${DateTime.now()} on ${Platform.localHostname}");
    start.writeln(template.template());
    var result = start.toString();
    for(final point in points) {
      final toInsert = AFCodeBuffer();
      final section = sections[point.key];
      if(section == null) {
        throw new AFException("Unknown insertion point ${point.key} while generating ${projectPath}");
      }
      section.execute(ctx, toInsert);

      // now, do the actual substituation.
      final re = RegExp("AfibReplacementPoint\\(" + point.key + "\\)");
      List<RegExpMatch> matches = List<RegExpMatch>.of(re.allMatches(result));
      final insert = toInsert.withIndent(point.indent);
      result = result.replaceAll(re, insert);
    }

    String path = AFProjectPaths.projectPathFor(projectPath);
    ctx.output.writeLine("Wrote result to $path");
    final file = File(path);
    file.writeAsStringSync(result);
  }
}
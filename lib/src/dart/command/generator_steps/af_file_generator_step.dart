
import 'dart:io';

import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_template_source.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_exception.dart';

/// A step that generates an entire file, which can contain expandable
/// code segments within it.
class AFFileGeneratorStep extends AFSourceGeneratorStep {
  final AFTemplateSource template;
  final List<String> resultPath;
  final sections = Map<String, AFSectionGenerator>();

  AFFileGeneratorStep(this.template, this.resultPath);

  /// Set a handler for a dynamic section (e.g. [!insert_code_here!] in the template)
  void setDynamicHandler(AFSectionGenerator step) {
    sections[step.key] = step;
  }

  @override
  bool validateBefore(AFArgs args, AFConfig afConfig, AFCommandOutput output) {
    List<AFTemplateInsertionPoint> points = template.findInsertionPoints();
    for(final point in points) {
      if(!sections.containsKey(point.key)) {
        output.writeErrorLine("Missing dynamic section handler ${point.key} while generating ${resultPath}");
        return false;
      }
    }
    return true;
  }

  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {
    List<AFTemplateInsertionPoint> points = template.findInsertionPoints();
    final start = StringBuffer();
    start.writeln("// File last generated at ${DateTime.now()} on ${Platform.localHostname}");
    start.writeln(template.template());
    var result = start.toString();
    for(final point in points) {
      final toInsert = AFCodeBuffer();
      final section = sections[point.key];
      if(section == null) {
        throw new AFException("Unknown insertion point ${point.key} while generating ${resultPath}");
      }
      section.execute(args, afibConfig, output, toInsert);

      // now, do the actual substituation.
      final re = RegExp("\\[!" + point.key + "!\\]");
      List<RegExpMatch> matches = List<RegExpMatch>.of(re.allMatches(result));
      final insert = toInsert.withIndent(point.indent);
      result = result.replaceAll(re, insert);
    }

    String path = AFProjectPaths.projectPathFor(resultPath);
    output.writeLine("Wrote result to $path");
    final file = File(path);
    file.writeAsStringSync(result);
  }
  
  
}
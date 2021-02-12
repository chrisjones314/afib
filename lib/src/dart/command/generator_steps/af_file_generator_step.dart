// @dart=2.9
import 'dart:io';

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_code/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';
import 'package:afib/src/dart/utils/af_exception.dart';

/// A step that generates an entire file, which can contain expandable
/// code segments within it.
class AFFileGeneratorStep extends AFSourceGenerationStep {
  final List<String> projectPath;
  final localGenerators = AFGeneratorRegistry();

  AFFileGeneratorStep(this.projectPath);


  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    final output = ctx.output;
    final template = ctx.templates.templateForFile(this.projectPath);
    final points = template.findReplacementPoints();
    for(final point in points) {
      if(!localGenerators.hasGeneratorFor(point) && !ctx.generators.hasGeneratorFor(point)) {
        output.writeErrorLine("Missing dynamic section handler ${point.key} while generating $projectPath");
        return false;
      }
    }
    return true;
  }

  void execute(AFCommandContext ctx, AFGeneratedFiles files) {
    final template = ctx.templates.templateForFile(this.projectPath);
    final file = files.fileFor(ctx.templates, this.projectPath);

    final points = template.findReplacementPoints();
    final start = StringBuffer();
    if(projectPath.last.contains(".g.")) {
      // only write this for files that get re-generated.  Not those that are generated once when they 
      // are created.
      start.writeln("// File last generated at ${DateTime.now()} on ${Platform.localHostname}");
    }
    start.writeln(template.template);
    final result = replacePoints(ctx, start.toString(), points, localGenerators);
    file.updateContent(ctx.o, result);
  }

  static String replacePoints(AFCommandContext ctx, String source, List<AFTemplateReplacementPoint> points, AFGeneratorRegistry localGenerators) {
    var result = source;
    for(final point in points) {
      final toInsert = AFCodeBuffer();
      var gen = localGenerators?.generatorFor(point);
      if(gen == null) {
        gen = ctx.generators.generatorFor(point);
      }
      if(gen == null) {
        throw AFException("Unknown insertion point ${point.key}");
      }
      gen.execute(ctx, toInsert);

      // now, do the actual substituation.
      final re = RegExp("${AFCodeGeneratorWithTemplate.replacementPoint}\\(${point.key}\\)");
      final insert = toInsert.withIndent(point.indent);
      result = result.replaceAll(re, insert);
    }
    return result;    
  }
}
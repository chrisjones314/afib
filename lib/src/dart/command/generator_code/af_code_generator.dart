
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/generator_code/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';

/// generates a section of code within a file.
abstract class AFCodeGenerator extends AFItemWithNamespace {

  AFCodeGenerator(String namespace, String key): super(namespace, key);
  void execute(AFCommandContext ctx, AFCodeBuffer buffer);

  static String toSnakeCase(String convert) {
    final sb = StringBuffer();
    for(var i = 0; i < convert.length; i++) {
      final c = convert[i];
      if(c == c.toUpperCase()) {
        if(i > 0) {
          sb.write("_");
        }
        sb.write(c.toLowerCase());
      } else {
        sb.write(c);
      }
    }
    return sb.toString().toLowerCase();
  }  

  static String toCapitalFirstLetter(String convert) {
    return "${convert[0].toUpperCase()}${convert.substring(1)}";
  }
}

class AFStaticCodeGenerator extends AFCodeGenerator {
  final String line;
  AFStaticCodeGenerator(String namespace, String key, this.line): super(namespace, key);
  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    buffer.write(line);
  }

  

}

class AFCodeGeneratorWithTemplate extends AFCodeGenerator {
  static const replacementPoint = 'AFRP';
  final bool writeLine;
  final localGenerators = AFGeneratorRegistry();

  final AFStatementSourceTemplate template;
  AFCodeGeneratorWithTemplate(this.template, {this.writeLine = true}): super(template.namespace, template.key);

  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    final content = AFFileGeneratorStep.replacePoints(ctx, template.template, template.findReplacementPoints(), localGenerators);
    if(writeLine) {
      buffer.writeLine(content);
    } else {
      buffer.write(content);
    }
  }
}




import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';

class AFIDCodeGenerator extends AFCodeGenerator {
  final String kind;
  final String id;
  AFIDCodeGenerator(this.kind, this.id): super(kind);  

  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    final uppercaseKind = kind[0].toUpperCase() + kind.substring(1);
    buffer.write('static final ');
    buffer.write(id);
    buffer.write(' = AF');
    buffer.write(uppercaseKind);
    buffer.write('ID("');
    buffer.write(id);
    buffer.writeLine('");');
  }

  @override
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    return true;
  }
}

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';

/// generates a section of code within a file.
abstract class AFCodeGenerator extends AFSourceGeneratorStep {
  final String key;
  AFCodeGenerator(this.key);  

  void execute(AFCommandContext ctx, AFCodeBuffer buffer);
}
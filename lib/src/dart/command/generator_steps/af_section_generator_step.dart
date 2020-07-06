
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/utils/af_config.dart';

/// generates a section of code within a file.
abstract class AFSectionGenerator extends AFSourceGeneratorStep {
  final String key;
  AFSectionGenerator(this.key);  

  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output, AFCodeBuffer buffer);
}
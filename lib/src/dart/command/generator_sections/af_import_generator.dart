

import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';
import 'package:afib/src/dart/utils/af_config.dart';

class AFImportSectionGenerator extends AFSectionGenerator {
  final String package;
  AFImportSectionGenerator(String key, this.package): super(key);

  @override
  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output, AFCodeBuffer buffer) {
    buffer.writeLine("import \'$package\';");
  }

    
  @override
  bool validateBefore(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {
    return true;
  }
}

class AFImportCommandGenerator extends AFImportSectionGenerator {
  AFImportCommandGenerator(): super("import_afib_command", "package:afib/afib_command.dart");
}
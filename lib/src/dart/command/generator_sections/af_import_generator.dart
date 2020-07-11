

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';

class AFImportSectionGenerator extends AFCodeGenerator {
  final String package;
  AFImportSectionGenerator(String key, this.package): super(key);

  @override
  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    buffer.writeLine("import \'$package\';");
  }

    
  @override
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    return true;
  }
}

class AFImportCommandGenerator extends AFImportSectionGenerator {
  AFImportCommandGenerator(): super("import_afib_command", "package:afib/afib_command.dart");
}

class AFImportDartGenerator extends AFImportSectionGenerator {
  AFImportDartGenerator(): super("import_afib_dart", "package:afib/afib_dart.dart");
}
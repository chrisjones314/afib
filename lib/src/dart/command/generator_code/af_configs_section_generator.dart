

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_code/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';

class AFConfigsSectionGenerator extends AFCodeGenerator {
  AFConfigsSectionGenerator(): super(AFConfigEntries.afNamespace, "configuration_entries");

  @override
  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    final afibConfig = ctx.afibConfig;
    final entries = AFItemWithNamespace.sortIterable<AFConfigEntry>(afibConfig.all);
    for(final entry in entries) {
      String codeVal = entry.codeValue(afibConfig);
      if(codeVal != null) {
        buffer.writeLine("config.setValue(AFConfigEntries.${entry.key}, $codeVal);");
      }
    }
  }
  
  @override
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
      return true;
  }


}
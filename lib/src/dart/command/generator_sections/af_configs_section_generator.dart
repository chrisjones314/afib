

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_steps/af_section_generator_step.dart';
import 'package:afib/src/dart/utils/af_config.dart';

class AFConfigsSectionGenerator extends AFSectionGenerator {
  AFConfigsSectionGenerator(): super("configuration_entries");

  @override
  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output, AFCodeBuffer buffer) {
    final entries = AFItemWithNamespace.sortIterable<AFConfigEntry>(afibConfig.all);
    for(final entry in entries) {
      String codeVal = entry.codeValue(afibConfig);
      if(codeVal != null) {
        buffer.writeLine("config.setValue(AFConfigEntries.${entry.key}, $codeVal);");
      }
    }
  }
  
  @override
  bool validateBefore(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {
      return true;
  }


}
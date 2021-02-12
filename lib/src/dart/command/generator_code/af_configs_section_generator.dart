// @dart=2.9
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/generator_code/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';

class AFConfigsSectionGenerator extends AFCodeGenerator {
  final AFConfig source;
  final List<AFConfigEntry> entries;
  AFConfigsSectionGenerator({this.source, this.entries}): super(AFConfigEntries.afNamespace, "configuration_entries");

  @override
  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    final afibConfig = this.source ?? ctx.afibConfig;
    final scope = this.entries ?? afibConfig.all;
    final sorted = AFItemWithNamespace.sortIterable<AFConfigEntry>(scope);
    for(final entry in sorted) {
      final codeVal = entry.codeValue(afibConfig);
      if(codeVal != null) {
        buffer.writeLine("config.setValue(AFConfigEntries.${entry.key}, $codeVal);");
      }
    }
  }
  
}
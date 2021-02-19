// @dart=2.9
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/generator_code/af_code_buffer.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFConfigsSectionGenerator extends AFCodeGenerator {
  final AFConfig source;
  final List<AFConfigItem> entries;
  AFConfigsSectionGenerator({this.source, this.entries}): super(AFConfigEntries.afNamespace, "configuration_entries");

  @override
  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    final afibConfig = AFibD.config;
    final scope = this.entries ?? afibConfig.all;
    final sorted = scope.toList();
    AFConfigItem.sortByOrdinal(sorted); //AFItemWithNamespace.sortIterable<AFConfigEntry>(scope);
    for(final entry in sorted) {
      final comment = entry.comment();
      final codeVal = entry.codeValue(afibConfig);
      if(codeVal != null) {
        buffer.writeLine(comment);
        buffer.writeLine("config.setValue(\"${entry.name}\", $codeVal);");
        buffer.writeLine("");
      }
    }
  } 
}

import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/code_generation/af_code_buffer.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class DeclareConfigEntriesT extends AFDynamicSourceTemplate {
  final AFConfig source;
  final List<AFConfigurationItem> entries;

  DeclareConfigEntriesT(this.source, this.entries);
    
  List<String> createLinesWithOptions(AFCommandContext context, List<String> options) {
    final afibConfig = AFibD.config;
    final scope = this.entries ?? afibConfig.all;
    final sorted = scope.toList();
    AFConfigurationItem.sortByOrdinal(sorted);
    final buffer = AFCodeBuffer.empty();
    for(final entry in sorted) {
      final comment = entry.comment();
      final codeVal = entry.codeValue(afibConfig);
      if(codeVal != null) {
        buffer.addLineAtEnd(comment);
        buffer.addLineAtEnd("config.setValue(\"${entry.name}\", $codeVal);");
        buffer.addLineAtEnd("");
      }
    }
    return buffer.lines;
  } 

}

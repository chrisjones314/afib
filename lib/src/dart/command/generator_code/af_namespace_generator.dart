
import 'package:afib/src/dart/command/generator_code/af_code_buffer.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/generator_code/af_code_generator.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class AFNamespaceGenerator extends AFCodeGenerator {
  
  AFNamespaceGenerator(): super(AFConfigEntries.afNamespace, "uppercase_app_namespace");

  @override
  void execute(AFCommandContext ctx, AFCodeBuffer buffer) {
    final appNS = ctx.afibConfig.stringFor(AFConfigEntries.appNamespace);
    buffer.write(appNS.toUpperCase());
  }
}

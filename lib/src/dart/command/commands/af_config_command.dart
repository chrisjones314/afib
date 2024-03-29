
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/templates/core/dynamic/dynamic_config_entries.t.dart';
import 'package:afib/src/dart/command/templates/core/files/config.t.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;


/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFConfigCommand extends AFCommand { 
  @override
  final name = "config";
  @override
  String get description {
    return "Set configuration values in initialization/${AFibD.config.appNamespace}_config.g.dart";
  } 

  @override
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable config [--one or more config options to modify]

$descriptionHeader
  $description

$optionsHeader
  See the file ${AFibD.config.appNamespace}_config.g.dart, which contains comments with the command line syntax for each option.
''';
  }

  static void updateConfig(AFCommandContext ctx, AFConfig config, List<AFConfigurationItem> items, args.ArgResults? argResults) {
    final output = ctx.output;
    // go through all the options that were set, and convert them into values
    // in the config.
    for(final entry in items) {
      if(!entry.allowedIn(AFConfigurationItem.validContextConfigCommand)) {
        continue;
      }
      final key = entry.name;
      final value = ctx.findArgument(key);
      if(value == null) {
        continue;
      }

      if(value is List && value.isEmpty) {
        continue;
      }

      final error = entry.validate(value);
      if(error != null) {
        output.writeErrorLine(error);
        return;
      }

      entry.setValue(config, value);

      output.writeTwoColumns(col1: "set ", col2: "${entry.name} = $value");
    }
  } 
  
  static void writeUpdatedConfig(AFCommandContext ctx) {
    final generator = ctx.generator;
    final projectPath = generator.pathAfibConfig;
    generator.overwriteFile(ctx, projectPath, ConfigT(), insertions: {
        ConfigT.insertConfigEntries: DynamicConfigEntriesT(AFibD.config, AFibD.configEntries)
    });
    
  }

  @override
  Future<void> execute(AFCommandContext context) async {    

    updateConfig(context, AFibD.config, AFibD.configEntries, context.arguments);
    writeUpdatedConfig(context);

    // replace any default 
    context.generator.finalizeAndWriteFiles(context);

  }
}
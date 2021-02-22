
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:args/args.dart' as args;


/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFConfigCommand extends AFCommand { 
  final name = "config";
  final description = "Set configuration values in afib.g.dart";

  @override
  void registerArguments(args.ArgParser args) {
    for(final option in AFibD.configEntries) {
      if(option.allowedIn(AFConfigurationItem.validContextConfigCommand)) {
        option.addArguments(args);
      }
    }
  }

  static void updateConfig(AFCommandContext ctx, AFConfig config, List<AFConfigurationItem> items, args.ArgResults argResults) {
    final output = ctx.output;
    // go through all the options that were set, and convert them into values
    // in the config.
    for(final entry in items) {
      if(!entry.allowedIn(AFConfigurationItem.validContextConfigCommand)) {
        continue;
      }
      final key = entry.name;
      final value = argResults[key];
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
    }
  } 
  
  @override
  void execute(AFCommandContext ctx, args.ArgResults args) {    
    final output = ctx.output;

    updateConfig(ctx, AFibD.config, AFibD.configEntries, args);



    // now, write out that configuration to the afib.g.dart file.
    final generateCmd = ctx.definitions.generateCommand;
    final configGenerator = generateCmd.configGenerator;
    final files = ctx.files;
    if(!configGenerator.validateBefore(ctx, files)) {
      return;
    }
    configGenerator.execute(ctx, files);    

    files.saveChangedFiles(output);
  }
}
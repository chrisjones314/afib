
import 'package:afib/id.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_error.dart';
import 'package:afib/src/dart/command/templates/dynamic/declare_config_entries.t.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
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

  static void updateConfig(AFCommandContext ctx, AFConfig config, List<AFConfigurationItem> items, args.ArgResults? argResults) {
    final output = ctx.output;
    // go through all the options that were set, and convert them into values
    // in the config.
    for(final entry in items) {
      if(!entry.allowedIn(AFConfigurationItem.validContextConfigCommand)) {
        continue;
      }
      final key = entry.name;
      final value = argResults?[key];
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
  
  static void writeUpdatedConfig(AFCommandContext ctx) {
    final generator = ctx.generator;
    final projectPath = generator.afibConfigPath;
    final configFile = generator.overwriteFile(ctx, projectPath, AFUISourceTemplateID.fileConfig);
    configFile.replaceTemplate(ctx, AFUISourceTemplateID.dynConfigEntries, DeclareConfigEntriesT(AFibD.config, AFibD.configEntries));

    // replace any default 
    generator.finalizeAndWriteFiles(ctx);
  }

  @override
  void execute(AFCommandContext ctx) {    

    final unnamed = ctx.unnamedArguments;
    if(unnamed != null && unnamed.isNotEmpty) {
      throw AFCommandError("The command has extra unrecognized arguments, did you forgot -- before an argument?");
    }

    updateConfig(ctx, AFibD.config, AFibD.configEntries, ctx.arguments);
    writeUpdatedConfig(ctx);
  }
}
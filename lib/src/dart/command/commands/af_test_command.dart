
import 'dart:io';

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;

class AFTestCommand extends AFCommand { 

  final name = "test";
  final description = "Run tests, you can specify any prototype name, test name, or any of the values for afib.dart help config's --tests-enabled option";

  @override 
  void registerArguments(args.ArgParser argsParser) {
    AFConfigEntries.testSize.addArguments(argParser);
    AFConfigEntries.testOrientation.addArguments(argParser);
  }

  @override
  void execute(AFCommandContext ctx, args.ArgResults args) {
    final config = AFibD.config;
    AFConfigEntries.testsEnabled.setValue(config, ctx.unnamedArguments(args));
    AFConfigCommand.updateConfig(ctx, config, [AFConfigEntries.testSize, AFConfigEntries.testOrientation], argResults);

    final generateCmd = ctx.definitions.generateCommand;
    final configGenerator = generateCmd.configGenerator;
    final files = ctx.files;
    if(!configGenerator.validateBefore(ctx, files)) {
      return;
    }
    configGenerator.execute(ctx, files);    
    files.saveChangedFiles(ctx.out);
      
    Process.start('flutter', ['test', AFProjectPaths.relativePathFor(AFProjectPaths.afTestPath)]).then((process) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);      
    });

    // reset the local config file to run all tests, in case they run 'flutter test'  
  }
}

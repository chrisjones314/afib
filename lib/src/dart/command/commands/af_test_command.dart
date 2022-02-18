
import 'dart:io';

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart' as args;
import 'package:collection/collection.dart';

class AFTestCommand extends AFCommand { 

  final name = "test";
  final description = "Run tests, you can specify any prototype name, test name, or any of the values for afib.dart help config's --tests-enabled option";

  @override 
  void registerArguments(args.ArgParser argsParser) {
    AFConfigEntries.testSize.addArguments(argParser);
    AFConfigEntries.testOrientation.addArguments(argParser);
  }

  @override
  void execute(AFCommandContext ctx) {
    final config = AFibD.config;
    AFConfigEntries.testsEnabled.setValue(config, ctx.unnamedArguments);
    _updateRecentTests(config, ctx.unnamedArguments);


    AFConfigCommand.updateConfig(ctx, config, [AFConfigEntries.testSize, AFConfigEntries.testOrientation], argResults);
    AFConfigCommand.writeUpdatedConfig(ctx);
      
    Process.start('flutter', ['test', AFProjectPaths.relativePathFor(AFProjectPaths.afTestPath)]).then((process) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);      
    });
    // reset the local config file to run all tests, in case they run 'flutter test'  
  }

  void _updateRecentTests(AFConfig config, List<String>? args) {
    if(args == null) {
      return;
    }
    final prefixes = [AFStateTestID.stateTestPrefix, AFScreenTestID.screenTestPrefix, AFPrototypeID.prototypePrefix];

    final current = config.recentTests;
    var result = List<String>.from(current);
    for(final arg in args) {
      final found = prefixes.firstWhereOrNull((prefix) => arg.contains("_${prefix}_"));
      if(found == null) {
        continue;
      }

      final idx = current.indexOf(arg);
      if(idx >= 0) {
        result.removeAt(idx);
      } 
      result.insert(0, arg);
    }
    if(result.length > 5) {
      result = result.slice(0, 5).toList();
    }

    AFConfigEntries.testsRecent.setValue(config, result);

  }
}

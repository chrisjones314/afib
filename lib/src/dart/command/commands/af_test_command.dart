
import 'dart:io';

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:collection/collection.dart';

class AFTestCommand extends AFCommand { 

  @override
  final name = "test";
  @override
  final description = "Run tests, you can specify any prototype name, test name, or any of the values for afib.dart help config's --tests-enabled option";


  @override
  String get usage {
    return '''
$usageHeader
  $nameOfExecutable test [${AFConfigEntries.testsEnabled.argumentHelpShort}]

$descriptionHeader
  $description

$optionsHeader
  ${AFConfigEntries.testsEnabled.argumentHelp}
  
''';
  }

  @override
  Future<void> execute(AFCommandContext context) async {
    final config = AFibD.config;
    AFConfigEntries.testsEnabled.setValue(config, context.rawArgs);
    _updateRecentTests(config, context.rawArgs);


    AFConfigCommand.updateConfig(context, config, [AFConfigEntries.testSize, AFConfigEntries.testOrientation], context.arguments);
    AFConfigCommand.writeUpdatedConfig(context);
    context.generator.finalizeAndWriteFiles(context);
      
    final process = await Process.start('flutter', ['test', AFProjectPaths.relativePathFor(AFProjectPaths.afTestPath)]);
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);      
    // reset the local config file to run all tests, in case they run 'flutter test'  

    // pass the exit code from the test back to the parent.
    final ec = await process.exitCode;
    exitCode = ec;
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

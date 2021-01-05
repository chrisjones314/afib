import 'dart:io';

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/generators/af_config_file_generator.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class AFTestCommand extends AFCommand { 
  static const cmdKey = "test";

  AFTestCommand(): super(AFConfigEntries.afNamespace, cmdKey, 0, 10);

  @override
  String get shortHelp => "Run afib tests conveniently";

  void writeLongHelp(AFCommandContext ctx, String subCommand) {
    writeUsage(ctx, cmdKey, "[${AFConfigEntries.enabledTestList.argumentString}]*");
    startArguments(ctx);
    writeConfigArgument(ctx, AFConfigEntries.enabledTestList);
  }


  @override
  void execute(AFCommandContext ctx) {
    // make sure we are in the project root.
    if(!errorIfNotProjectRoot(ctx.o)) {
      return;
    }

    ctx.afibConfig.setValue(AFConfigEntries.enabledTestList, ctx.a.listFrom());

    // write out the local configuration file.
    final generator = AFConfigFileGenerator();
    
    final files = ctx.files;
    if(!generator.validateBefore(ctx, files)) {
      return;
    }
    generator.execute(ctx, files);    
    files.saveChangedFiles(ctx.o);
      
    Process.start('flutter', ['test', AFProjectPaths.relativePathFor(AFProjectPaths.afTestPath)]).then((process) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);      
    });

    // reset the local config file to run all tests, in case they run 'flutter test'  

    
  }
}

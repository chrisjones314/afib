import 'dart:io';

import 'package:afib/afib_dart.dart';
import 'package:afib/src/commands/af_command.dart';
import 'package:afib/src/commands/af_args.dart';
import 'package:afib/src/commands/af_templates.dart';

/// Parent for commands executed through the afib command line app.
class EnvironmentCommand extends AFCommand { 

  EnvironmentCommand(): super("environment", 1, 1);

  void execute(AFArgs args) {    
    String env = args.first;
    final allEnvs = AFConfigConstants.allEnvironments;
    if(!allEnvs.contains(env)) {
      printError("Invalid environment $env");
      return;
    }

    // we need to load in the templates.
    AFTemplates templates = AFTemplates(Platform.script.toFilePath());
    AFTemplate environment = templates.environment(env: env);
    environment.write();
    print("Switched to environment $env");
  }

  @override
  String shortHelp() {
    return "Set the environment to production | debug | test | prototype";
  }
}

import 'package:afib/src/dart/utils/af_config_constants.dart';
import 'package:afib/src/commands/af_args.dart';
import 'package:afib/src/commands/af_template_command.dart';
import 'package:afib/src/commands/af_templates.dart';

/// Parent for commands executed through the afib command line app.
class EnvironmentCommand extends AFTemplateCommand { 

  EnvironmentCommand(): super("environment", 1, 1);

  @override
  void executeTemplate(AFArgs args, AFTemplates templates) {    
    String env = args.first;
    final allEnvs = AFConfigConstants.allEnvironments;
    if(!allEnvs.contains(env)) {
      printError("Invalid environment $env");
      return;
    }

    templates.writeEnvironment(environment: env);
    print("Switched to environment $env");
  }

  @override
  String shortHelp() {
    return "Set the environment to production | debug | test | prototype";
  }
}
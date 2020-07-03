
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_templates.dart';
import 'package:afib/src/dart/utils/af_config.dart';

/// Parent for commands executed through the afib command line app.
abstract class AFTemplateCommand extends AFCommand { 

  AFTemplateCommand(String package, String name, int minParams, int maxParams): super(package, name, minParams, maxParams);

  @override
  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {    
    // just be sure we are at the root of the afib project before we try
    // to write any files.
    
    AFTemplates templates = AFTemplates();
    if(templates.verifyCurrentIsAfibProject()) {
      executeTemplate(args, afibConfig, templates, output);
    } else {
      output.writeError("Please run this command from the root of your afib project");
    }
  }

  void executeTemplate(AFArgs args, AFConfig afibConfig, AFTemplates templates, AFCommandOutput output);
}


import 'package:afib/src/commands/af_args.dart';
import 'package:afib/src/commands/af_command.dart';
import 'package:afib/src/commands/af_templates.dart';

/// Parent for commands executed through the afib command line app.
abstract class AFTemplateCommand extends AFCommand { 

  AFTemplateCommand(String name, int minParams, int maxParams): super(name, minParams, maxParams);

  @override
  void execute(AFArgs args) {    
    // just be sure we are at the root of the afib project before we try
    // to write any files.
    
    AFTemplates templates = AFTemplates();
    if(templates.verifyCurrentIsAfibProject()) {
      executeTemplate(args, templates);
    }
  }

  void executeTemplate(AFArgs args, AFTemplates templates);
}

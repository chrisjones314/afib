
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generators/af_new_project_generator.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

/// Command that displays or modified values from [AFConfig], and
/// that modifed values under the initialization/afib.g.dart.
class AFNewProjectCommand extends AFCommand { 
  static const cmdKey = 'new';


  AFNewProjectCommand(): super(AFConfigEntries.afNamespace, cmdKey, 2, 2);

  void writeLongHelp(AFCommandContext ctx, String subCommand) {
    writeUsage(ctx, cmdKey, "${AFConfigEntries.appNamespace.argumentString} ${AFConfigEntries.projectName.argumentString}");
    startArguments(ctx);
    writeConfigArgument(ctx, AFConfigEntries.appNamespace);
    writeConfigArgument(ctx, AFConfigEntries.projectName);
        
  }


  @override
  void execute(AFCommandContext ctx) {    
    final namespace = ctx.args.first;
    final projectName = ctx.args.second;

    // first, validate that the namespace is valid.
    String err = AFConfigEntries.appNamespace.validate(namespace);
    if(err != null) {
      ctx.output.writeErrorLine(err);
      return;
    }

    err = AFConfigEntries.projectName.validate(projectName);
    if(err != null) {
      ctx.output.writeErrorLine(err);
      return;
    }

    /// setup the defaults.
    ctx.afibConfig.setValue(AFConfigEntries.appNamespace, namespace);
    ctx.afibConfig.setValue(AFConfigEntries.projectName, projectName);
    ctx.afibConfig.setValue(AFConfigEntries.environment, AFConfigEntryEnvironment.debug);
    ctx.afibConfig.setValue(AFConfigEntries.internalLogging, AFConfigEntryBool.falseValue);
    ctx.afibConfig.setValue(AFConfigEntries.enabledTestList, []);

    // There is no point in trying to expose this generator for manipulation, because the 
    // 'new' command occurs in the afib command, which cannot be extended/customized. 
    final generator = AFNewProjectGenerator(ctx);
    final files     = AFGeneratedFiles();
    
    if(!generator.validateBefore(ctx, files)) {
      return;
    }

    generator.execute(ctx, files);

    files.saveChangedFiles(ctx.o);
  }

  @override
  String get shortHelp => "create a new AFib project in a specified sub-folder of the current folder";

}
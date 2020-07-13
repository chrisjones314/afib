

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_create_folder_step.dart';
import 'package:afib/src/dart/command/generators/af_config_file_generator.dart';

class AFNewProjectGenerator extends AFSourceGenerator {
  static const cmdKey = "new";
  
  /// no help here, because this generator is only accessible through the 'new' command
  AFNewProjectGenerator(AFCommandContext ctx) : super(AFConfigEntries.afNamespace, cmdKey, "") {
    final projectFolder = ctx.afibConfig.projectFolderName;
    addStep(AFCreateProjectFolderStep([projectFolder]));
    addStep(AFConfigFileGenerator());
    addStep(AFIDFileGenerator());
  }
}
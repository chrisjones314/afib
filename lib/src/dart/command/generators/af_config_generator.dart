

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generators/af_config_file_generator.dart';

class AFConfigGenerator extends AFSourceGenerator {
  static const cmdKey = "config";
  
  AFConfigGenerator() : super(AFConfigEntries.afNamespace, cmdKey, "Update a single configuration parameter in ${AFProjectPaths.afibConfigFile}") {
    addStep(AFConfigFileGenerator());
  }
}


import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_sections/af_configs_section_generator.dart';
import 'package:afib/src/dart/command/generator_sections/af_import_generator.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';
import 'package:afib/src/dart/command/templates/afib.t.dart';

class AFConfigGenerator extends AFSourceGenerator {
  static const genKey = "config";
  
  AFConfigGenerator() : super(AFConfigEntries.afNamespace, genKey, "Update a single configuration parameter in ${AFProjectPaths.afibConfigFile}") {
    final genAfib = AFFileGeneratorStep(AFibT(), AFProjectPaths.afibConfigPath);
    genAfib.setDynamicHandler(AFConfigsSectionGenerator());
    genAfib.setDynamicHandler(AFImportCommandGenerator());
    addStep(genAfib);
  }
}
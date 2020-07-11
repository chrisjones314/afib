

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_sections/af_configs_section_generator.dart';
import 'package:afib/src/dart/command/generator_sections/af_import_generator.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';
import 'package:afib/src/dart/command/templates/afib.t.dart';

class AFConfigGenerator extends AFSourceGenerator {
  static const cmdKey = "config";
  
  AFConfigGenerator() : super(AFConfigEntries.afNamespace, cmdKey, "Update a single configuration parameter in ${AFProjectPaths.afibConfigFile}") {
    final genAfib = AFFileGeneratorStep(AFProjectPaths.afibConfigPath);
    genAfib.setCodeGenerator(AFConfigsSectionGenerator());
    genAfib.setCodeGenerator(AFImportCommandGenerator());
    addStep(genAfib);
  }
}


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/generator_code/af_configs_section_generator.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';

class AFConfigFileGenerator extends AFFileGeneratorStep {
    
  AFConfigFileGenerator(): super(AFProjectPaths.afibConfigPath) {
    localGenerators.registerGenerator(AFConfigsSectionGenerator());
  }
}

class AFIDFileGenerator extends AFFileGeneratorStep {
    
  AFIDFileGenerator(): super(AFProjectPaths.idPath);
}

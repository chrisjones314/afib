
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';
import 'package:afib/src/dart/command/generators/af_config_generator.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';


/// A single process in the 
abstract class AFSourceGeneratorStep {

  /// Validate that all the necessary templates, insertion points, and parameters
  /// are valid prior to doing the source code generation.
  /// 
  /// If they are not, output an error and return false.
  bool validateBefore(AFArgs args, AFConfig afibConfig, AFCommandOutput output);
}

/// A an algorithm that manipulates one or more pieces of code, consisting
/// of a serious of [AFSourceGeneratorStep]
class AFSourceGenerator extends AFItemWithNamespace {
  final steps = List<AFFileGeneratorStep>();
  final String shortHelp;

  /// 
  AFSourceGenerator(String namespace, String key, this.shortHelp): super(namespace, key);

  void addStep(AFSourceGeneratorStep step) {
    steps.add(step);
  }

  /// Validates that all the steps are valid.
  bool validateBefore(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {
    for(final step in steps) {
      if(!step.validateBefore(args, afibConfig, output)) {
        return false;
      }
    }
    return true;
  }

  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {
    for(final step in steps) {
      step.execute(args, afibConfig, output);
    }
    
  }

  /// Writes out a single line help statement.
  void writeShortHelp(AFCommandOutput output, {int indent = 0}) {
    AFCommand.startCommandColumn(output, indent: indent);
    output.write(namespaceKey + " - ");
    AFCommand.startHelpColumn(output);
    output.writeLine(shortHelp);
  }

}

/// An extensible command used to generate source code from the command-line.
class AFGenerateCommand extends AFCommand {
  static const cmdKey = "generate";
  final generators = Map<String, AFSourceGenerator>();

  AFGenerateCommand(): super(AFConfigEntries.afNamespace, cmdKey, 1, 0) {
    registerGenerator(AFConfigGenerator());
  }

  void registerGenerator(AFSourceGenerator generator) {
    generators[generator.namespaceKey] = generator;
  }

  @override
  void execute(AFArgs args, AFConfig afibConfig, AFCommandOutput output) {
    final genKey = args.at(0);
    final generator = generators[genKey];
    if(generator == null) {
      output.writeErrorLine("Unknown generator $genKey, stopping.");
      return;
    }

    if(!generator.validateBefore(args, afibConfig, output)) {
      return;
    }

    generator.execute(args, afibConfig, output);
  }

  @override
  String get shortHelp {
    return "Generate source code elements such as screens, queries, and identifiers";
  }

  @override  
  void writeLongHelp(AFCommandOutput output, String subCommand) {
    writeShortHelp(output);
    if(subCommand == null) {
      AFCommand.emptyCommandColumn(output);
      AFCommand.startHelpColumn(output);
      output.writeLine("Use help generate <generator> for any of the following generators:");
      final gens = List<AFSourceGenerator>.of(generators.values);
      gens.sort( (l, r) { return l.namespaceKey.compareTo(r.namespaceKey); });
      for(final gen in gens) {
        gen.writeShortHelp(output, indent: 1);
      }
    }
  }
}
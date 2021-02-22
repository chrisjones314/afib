// @dart=2.9
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_test_command.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/command/templates/af_template_registry.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/command_runner.dart' as cmd;

/// Initialize commands that are used only from the afib command
/// line app itself (e.g. new).
void afRegisterAfibOnlyCommands(AFCommandExtensionContext commands) {
  commands.register(AFVersionCommand());
  //commands.register(AFNewProjectCommand());
}

/// Initialize afib comamnds that are used from the application-specific
/// commamd
void afRegisterAppCommands(AFCommandExtensionContext definitions) {
  definitions.register(AFVersionCommand());
  definitions.register(AFConfigCommand());
  definitions.register(AFGenerateCommand());
  definitions.register(AFTestCommand());
}

/// Used to initialize and execute commands available via afib_bootstrap
void afBootstrapCommandMain(AFDartParams paramsD, List<String> args) {
  _afCommandMain(paramsD, args, "afib_bootstrap", "Command used to create new afib projects", null, null, [
    afRegisterAppCommands
  ], null);
}

void afCommandStartup(void Function() onRun) {
  AFibD.registerGlobals();
  onRun();
}

void afAppCommandMain(AFDartParams paramsD, List<String> args, AFExtendBaseDelegate initBase, AFExtendBaseDelegate initBaseThirdParty, AFExtendCommandsDelegate initApp, AFExtendCommandsThirdPartyDelegate initExtend) {
  _afCommandMain(paramsD, args, "afib", "App-specific afib command", initBase, initBaseThirdParty, [
    afRegisterAppCommands,
    initApp
  ], initExtend);
}

void afUILibraryCommandMain(AFDartParams paramsD, List<String> args, AFExtendBaseDelegate initBase, AFExtendBaseDelegate initBaseThirdParty, AFExtendCommandsDelegate initApp, AFExtendCommandsThirdPartyDelegate initExtend) {
  _afCommandMain(paramsD, args, "afib", "App-specific afib command", initBase, initBaseThirdParty, [
    afRegisterAppCommands,
    initApp
  ], initExtend);
}

void _afCommandMain(AFDartParams paramsD, List<String> args, String cmdName, String cmdDescription, AFExtendBaseDelegate initBase, AFExtendBaseDelegate initBaseThirdParty, List<AFExtendCommandsDelegate> inits, AFExtendCommandsThirdPartyDelegate initExtend) {
  final definitions = AFCommandExtensionContext(paramsD: paramsD, commands: cmd.CommandRunner(cmdName, cmdDescription));
  final baseContext = AFBaseExtensionContext();
  if(initBase != null) {
    initBase(baseContext);
  }
  if(initBaseThirdParty != null) {
    initBaseThirdParty(baseContext);
  }

  // initialize the stuff that is accessible from dart/the command line.
  AFibD.initialize(paramsD);

  for(final init in inits) {
    init(definitions);
  }
  if(initExtend != null) {
    initExtend(definitions);
  }

  final generators = AFGeneratorRegistry();
  generators.registerGlobals();

  final ctx = AFCommandContext(
    output: AFCommandOutput(),
    generators: generators,
    templates: AFTemplateRegistry(),
    definitions: definitions,
  );

  definitions.finalize(ctx);

  
  /*
  final afibConfig = AFConfig();
  if(paramsD != null) {
    final configCmd = commands.findConfigCommand();
    configCmd.initAfibDefaults(afibConfig);
    paramsD.initAfib(afibConfig);
  }
  */

  definitions.execute(args);
}
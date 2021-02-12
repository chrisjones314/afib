// @dart=2.9
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_help_command.dart';
import 'package:afib/src/dart/command/commands/af_new_project_command.dart';
import 'package:afib/src/dart/command/commands/af_test_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// Initialize commands that are used only from the afib command
/// line app itself (e.g. new).
void afRegisterAfibOnlyCommands(AFCommands commands) {
  commands.register(AFHelpCommand(all: commands));
  commands.register(AFVersionCommand());
  commands.register(AFNewProjectCommand());
}

/// Initialize afib comamnds that are used from the application-specific
/// commamd
void afRegisterAppCommands(AFCommandExtensionContext definitions) {
  definitions.register(AFHelpCommand(all: definitions.commands));
  definitions.register(AFVersionCommand());
  definitions.register(AFConfigCommand());
  definitions.register(AFGenerateCommand());
  definitions.register(AFTestCommand());
}

/// Used to initialize and execute commands available via afib_bootstrap
void afBootstrapCommandMain(AFDartParams paramsD, AFArgs afArgs) {
  final commands = AFCommands(command: AFCommands.afCommandAfib);

  _afCommandMain(commands, paramsD, afArgs, [
    afRegisterAppCommands
  ]);
}

void afAppCommandMain(AFDartParams paramsD, AFArgs afArgs, AFExtendCommandsDelegate initApp) {
  final commands = AFCommands();
  _afCommandMain(commands, paramsD, afArgs, [
    afRegisterAppCommands,
    initApp
  ]);
}

void _afCommandMain(AFCommands commands, AFDartParams paramsD, AFArgs afArgs, List<AFExtendCommandsDelegate> inits) {
  final definitions = AFCommandExtensionContext(commands: commands, paramsD: paramsD);
  for(final init in inits) {
    init(definitions);
  }

  var command = "help";
  if(afArgs.hasCommand) {
    command = afArgs.command;
  }

  // initialize the stuff that is accessible from dart/the command line.
  AFibD.initialize(paramsD);
  final afibConfig = AFConfig();
  if(paramsD != null) {
    final configCmd = commands.findConfigCommand();
    configCmd.initAfibDefaults(afibConfig);
    paramsD.initAfib(afibConfig);
  }

  commands.execute(command, afArgs, afibConfig);
}
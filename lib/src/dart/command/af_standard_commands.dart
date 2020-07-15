

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/commands/af_help_command.dart';
import 'package:afib/src/dart/command/commands/af_new_project_command.dart';
import 'package:afib/src/dart/command/commands/af_test_command.dart';
import 'package:afib/src/dart/command/commands/af_version_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
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
void afRegisterAppCommands(AFDartParams params, AFCommands commands) {
  commands.register(AFHelpCommand(all: commands));
  commands.register(AFVersionCommand());
  commands.register(AFConfigCommand());
  commands.register(AFGenerateCommand());
  commands.register(AFTestCommand());
}

void afCommandMain(AFCommands commands, AFDartParams params, AFArgs afArgs) {
  String command = "help";
  if(afArgs.hasCommand) {
    command = afArgs.command;
  }

  // initialize the stuff that is accessible from dart/the command line.
  AFibD.initialize(params);
  final afibConfig = AFConfig();
  if(params != null) {
    final configCmd = commands.findConfigCommand();
    configCmd.initAfibDefaults(afibConfig);
    params.initAfib(afibConfig);
  }

  commands.execute(command, afArgs, afibConfig);
}


import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/command/commands/help_command.dart';
import 'package:afib/src/dart/command/commands/version_command.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

/// Initialize commands that are used only from the afib command
/// line app itself (e.g. new).
void afRegisterAfibOnlyCommands(AFCommands commands) {
  commands.register(HelpCommand(all: commands));
  commands.register(VersionCommand());
}

/// Initialize afib comamnds that are used from the application-specific
/// commamd
void afRegisterAppCommands(AFDartParams params, AFCommands commands) {
  commands.register(HelpCommand(all: commands));
  commands.register(VersionCommand());
  commands.register(AFConfigCommand());
}


void afCommandMain(AFCommands commands, AFDartParams params, List<String> args) {
  String command = "help";
  if(args.length > 0) {
    command = args[0];
  }

  // initialize the stuff that is accessible from dart/the command line.
  AFibD.initialize(params);
  final afibConfig = AFConfig();
  if(params != null) {
    params.initAfib(afibConfig);
  }

  commands.execute(command, args, afibConfig);
}
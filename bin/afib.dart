
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';

void main(List<String> args) {
  AFCommands commands = AFCommands(command: AFCommands.afCommandAfib);
  afRegisterAfibOnlyCommands(commands);
  afCommandMain(commands, null, args);
}



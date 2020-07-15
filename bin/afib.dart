
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';

void main(List<String> argsIn) {
  AFCommands commands = AFCommands(command: AFCommands.afCommandAfib);
  afRegisterAfibOnlyCommands(commands);
   var afArgs = AFArgs.create(argsIn);
   final debug = true;
   if(debug) {
     afArgs.debugResetTo("new td TodoList");
   }
  
  afCommandMain(commands, null, afArgs);
}



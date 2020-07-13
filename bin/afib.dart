
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';

void main(List<String> argsIn) {
  AFCommands commands = AFCommands(command: AFCommands.afCommandAfib);
  afRegisterAfibOnlyCommands(commands);
   var args = argsIn;
   final debug = true;
   if(debug) {
     args = List<String>();
     args.add("new");
     args.add("td");
     args.add("TodoList");
   }
  
  afCommandMain(commands, null, args);
}



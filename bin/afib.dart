
import 'package:afib/src/commands/af_command.dart';

void main(List<String> args) {
  AFCommands commands = AFCommands();
  String command = "help";
  if(args.length > 0) {
    command = args[0];
  }
  
  commands.execute(command, args);
}



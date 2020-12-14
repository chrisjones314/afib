
import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';

void main(List<String> argsIn) {
   var afArgs = AFArgs.create(argsIn);
   final debug = false;
   if(debug) {
     afArgs.debugResetTo("new td TodoList");
   }
  
  afBootstrapCommandMain(null, afArgs);
}



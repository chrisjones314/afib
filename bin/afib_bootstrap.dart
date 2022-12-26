import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';

void main(List<String> argsIn) {  
  final emptyParams = AFDartParams.createEmpty();
  final argsFull = AFArgs.create(argsIn);
  
  //argsFull.setDebugArgs("create app signin_test st --project-style eval-demo");
  //argsFull.setDebugArgs("create app signin_test st --project-style starter-minimal");
  //argsFull.setDebugArgs("create app signin_test st --project-style starter-signin");
  argsFull.setDebugArgs("create app signinfb_test stfb --project-style starter-signin-firebase");

  afBootstrapCommandMain(emptyParams, argsFull);
}



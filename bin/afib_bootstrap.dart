import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';

void main(List<String> argsIn) {  
  final emptyParams = AFDartParams.createEmpty();
  final argsFull = AFArgs.create(argsIn);
  
  argsFull.setDebugArgs("create app --package-name signinfb_test --package-code stfb --project-style app-starter-signin");
  afBootstrapCommandMain(emptyParams, argsFull);
}



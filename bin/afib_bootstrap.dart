import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';

void main(List<String> argsIn) {  
  final emptyParams = AFDartParams.createEmpty();
  final argsFull = AFArgs.create(argsIn);
  argsFull.setDebugArgs("create app --package-name test_install --package-code test --project-style app-starter-minimal");
  
  afBootstrapCommandMain(emptyParams, argsFull);
}



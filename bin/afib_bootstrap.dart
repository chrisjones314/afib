import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';

void main(List<String> argsIn) {  
  final emptyParams = AFDartParams.createEmpty();
  final argsFull = AFArgs.create(argsIn);
  
  argsFull.setDebugArgs("create app --package-name eval_example --package-code evex --project-style app-eval-demo");
  afBootstrapCommandMain(emptyParams, argsFull);
}



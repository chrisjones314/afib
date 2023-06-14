import 'package:afib/src/dart/command/af_args.dart';
import 'package:afib/src/dart/command/af_standard_commands.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';

void main(List<String> argsIn) {  
  final emptyParams = AFDartParams.createEmpty();
  final argsFull = AFArgs.create(argsIn);
  //argsFull.setDebugArgs("create app --package-name warning_test --package-code wt --project-style app-eval-demo --auto-install true --local-afib \"/Users/chrisjones/projects/afib\"");
  //argsFull.setDebugArgs('create app --package-name smoketest_minimal --package-code stmin --project-style app-starter-minimal --cwd /Users/chrisjones/temp/afib_smoketest/smoketest_minimal --auto-install true --local-afib /Users/chrisjones/projects/afib');
  argsFull.setDebugArgs("create app --package-name signinfb_test --package-code stfb --project-style app-starter-signin-firebase --auto-install true");

  //argsFull.setDebugArgs("--working-folder /Users/chrisjones/temp/afib_smoketest --local-afib /Users/chrisjones/projects/afib --auto-install");
  
  afBootstrapCommandMain(emptyParams, argsFull);
}



import 'package:afib/src/dart/command/af_standard_commands.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';

void main(List<String> argsIn) {  
  final emptyParams = AFDartParams.createEmpty();
  print("*********** Using debug arguments *********");
  argsIn = ["create", "app", "hellocounter", "HC"];
  //argsIn = ["version"];
  afBootstrapCommandMain(emptyParams, argsIn);
}






import 'package:afib/src/dart/command/af_source_template.dart';

class AFAppcodeAFibT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_command.dart';
import 'package:[!af_package_path]/initialization/extend/extend_third_party_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_third_party_command.dart';

/// The main function for the application-specific, extensible afib command-line
/// interface.
void main(List<String> args) {
  afCommandStartup(() async {
    final paramsD = createDartParams();
    var argsFull = AFArgs.create(args);
    
    // argsFull.setDebugArgs("your command arguments here");

    // execute the command.
    await afAppCommandMain(
      args: argsFull,
      paramsDart: paramsD, 
      extendBase: extendBase, 
      extendCommand: extendCommand, 
      extendThirdPartyBase: extendThirdPartyBase, 
      extendThirdPartyCommand: extendThirdPartyCommand,
    );
  });
}
''';
}


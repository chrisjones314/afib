


import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class CommandAFibT extends AFFileSourceTemplate {

  const CommandAFibT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "command_afib"],
  );

  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:$insertPackagePath/initialization/create_dart_params.dart';
import 'package:$insertPackagePath/initialization/install/install_base.dart';
import 'package:$insertPackagePath/initialization/install/install_command.dart';
import 'package:$insertPackagePath/initialization/install/install_base_library.dart';
import 'package:$insertPackagePath/initialization/install/install_command_library.dart';

/// The main function for the application-specific, extensible afib command-line
/// interface.
void main(List<String> args) {
  afCommandStartup(() async {
    final paramsD = createDartParams();
    var argsFull = AFArgs.create(args);
    
    // argsFull.setDebugArgs("your command arguments here");

    // execute the command.
    await af${insertLibKind}CommandMain(
      args: argsFull,
      paramsDart: paramsD, 
      installBase: installBase, 
      installBaseLibrary: installBaseLibrary, 
      installCommand: installCommand, 
      installCommandLibrary: installCommandLibrary,
    );
  });
}
''';
}


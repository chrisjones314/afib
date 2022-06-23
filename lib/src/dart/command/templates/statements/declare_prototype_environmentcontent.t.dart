import 'package:afib/src/dart/command/af_source_template.dart';

class DeclarePrototypeEnvironmentContentT extends AFSourceTemplate {
  final String template = '''
  // use this, plus AFEnvironment.wireframe to start up directly into a wireframe.
  // config.setStartupWireframe([!af_app_namespace(upper)]PrototypeID.yourWireframe);

  // use this, plus AFEnvironment.stateTest to startup directly into the terminal state of a state test.
  // config.setStartupStateTest([!af_app_namespace(upper)]StateTestID.yourStateTest);


  // use this, plus AFEnvironment.screenPrototype to startup directly into a screen prototype.
  // config.setStartupScreenPrototype(DFPrototypeID.searchScreenInitial);

  // use this to configure your favorite tests on the prototype home screen
  config.setFavoriteTests([
    // [!af_app_namespace(upper)]StateTestID.yourTestId,
  ]);
''';
}

 
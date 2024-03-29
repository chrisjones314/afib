import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetPrototypeEnvironmentImplT extends AFSourceTemplate {
  @override
  String get template => '''
  // use this, plus AFEnvironment.wireframe to start up directly into a wireframe.
  // config.setStartupWireframe(${insertAppNamespaceUpper}WireframeID.initial);

  // use this, plus AFEnvironment.stateTest to startup directly into the terminal state of a state test.
  // config.setStartupStateTest(${insertAppNamespaceUpper}StateTestID.yourStateTest);

  // use this, plus AFEnvironment.screenPrototype to startup directly into a screen prototype.
  // config.setStartupScreenPrototype(${insertAppNamespaceUpper}PrototypeID.searchScreenInitial);

  // use this to configure your favorite tests on the prototype home screen
  config.setFavoriteTests([
    // ${insertAppNamespaceUpper}StateTestID.yourTestId,
  ]);
''';
}

 
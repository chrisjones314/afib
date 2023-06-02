


import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetStateTestImplT extends AFCoreSnippetSourceTemplate {
  SnippetStateTestImplT(): super(templateFileId: "state_test_impl");

  @override
  String get template => '''
''';
}


class SnippetStateTestImplMinimalT extends AFCoreSnippetSourceTemplate {
  SnippetStateTestImplMinimalT(): super(templateFileId: "state_test_impl_minimal");

  @override
  List<String> get extraImports {
    return [
"import 'package:$insertPackagePath/query/simple/startup_query.dart';",
    ];
  }

  @override
  String get template => '''
// first, you will define query results using variants of 
// testContext.defineQueryResponse...
testContext.defineQueryResponseUnused<StartupQuery>();


// then, you will start your app, which will cause your StartupQuery to execute.
testContext.executeStartup();

// then, you will create your shortcuts, which cleanup executable state test syntax.
final shortcuts = ${AFSourceTemplate.insertAppNamespaceInsertion.upper}StateTestShortcuts(testContext);
final startupScreen = shortcuts.createStartupScreen();

// then, you execute screens and builds, to get access to SPIs, which you will use
// both to validate your app's UI state, and to simulate user actions in the UI.
startupScreen.executeScreen((e, screenContext) { 
  screenContext.executeBuild((spi) { 
    // this SPI doesn't really do anything yet, but real screens will have SPIs that
    // both expose the data used to render the UI in an easy-to-validate format, and 
    // expose event handlers that make it easy to simulate user actions.

    // NOTE: if you do not understand why you can only meaningfully invoke a single event 
    // handler per screenContext.executeBuild, you need to go back to the tutorial video
    // or docs.  Things aren't failing, you just don't understand how they work.
  });
});
''';
}


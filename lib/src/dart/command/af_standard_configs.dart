
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class AFConfigEntryEnvironment extends AFConfigEntryChoice {
  static const production = "production";
  static const debug = "debug";
  static const prototype = "prototype";
  static const testStore = "test_store";
  static const allEnvironments = [production, debug, prototype, testStore];

  AFConfigEntryEnvironment(): super(AFConfigEntries.afNamespace, "environment", production) {
    addChoice(debug, "");
    addChoice(production, "");
    addChoice(prototype, "Display a list of prototype screens, see initialization/test/screen_tests.dart");
    addChoice(testStore, "Used internally when doing state tests, typically not selected explicitly");
  }

  bool requiresPrototypeData(AFConfig config) {
    final env = config.stringFor(this);
    return env == prototype;
  }

  bool requiresTestData(AFConfig config) {
    final env = config.stringFor(this);
    return (env != production && env != debug);
  }

}


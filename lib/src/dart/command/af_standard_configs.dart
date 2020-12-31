
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class AFConfigEntryEnvironment extends AFConfigEntryEnumChoice<AFEnvironment> {
  static const allEnvironments = AFEnvironment.values;

  AFConfigEntryEnvironment(): super(AFConfigEntries.afNamespace, "environment", AFEnvironment.production) {
    addChoice(AFEnvironment.debug, "For debugging");
    addChoice(AFEnvironment.production, "For production");
    addChoice(AFEnvironment.prototype, "Interact with prototype screens, and run tests against them on the simulator");
    addChoice(AFEnvironment.test, "Used internally when command-line tests are executing");
  }

  bool requiresPrototypeData(AFConfig config) {
    final env = config.valueFor(this);
    return env == AFEnvironment.prototype;
  }

  bool requiresTestData(AFConfig config) {
    final env = config.valueFor(this);
    return (env != AFEnvironment.production && env != AFEnvironment.debug);
  }

}


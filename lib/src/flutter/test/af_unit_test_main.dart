
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/test/af_unit_tests.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// The main function which executes the tests defined in your initUnitTests function.
void afUnitTestMain(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD, AFFlutterParams paramsF) {
  if(!AFConfigEntries.enabledTestList.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.unitTests)) {
    return;
  }

  final tests = AFibF.unitTests;
  final contexts = List<AFUnitTestContext>();

  tests.tests.forEach((test) {
    if(AFConfigEntries.enabledTestList.isTestEnabled(AFibD.config, test.id)) {
      final context = AFUnitTestContext(test);
      test.execute(context);
      contexts.add(context);
    }
  });

  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  printTestResults(output, "Unit", baseContexts, stats);
}

import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/test/af_unit_tests.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';

/// The main function which executes the tests defined in your initUnitTests function.
void afUnitTestMain(AFCommandOutput output, AFTestStats stats, AFDartParams paramsD) {
  if(!AFConfigEntries.testsEnabled.isAreaEnabled(AFibD.config, AFConfigEntryEnabledTests.unitTests)) {
    return;
  }

  final tests = AFibF.g.unitTests;
  final contexts = <AFUnitTestContext>[];
  const testKind = "Unit";
  final localStats = AFTestStats();

  for(final test in tests.tests) {
    if(AFConfigEntries.testsEnabled.isTestEnabled(AFibD.config, test.id)) {
      if(localStats.isEmpty) {
        printTestKind(output, testKind);
      }

      final context = AFUnitTestContext(test);
      test.execute(context);
      contexts.add(context);
      output.indent();
      printTestResult(output, testKind, context, localStats);
      output.outdent();
      context.finishAndUpdateStats(localStats);
    }
  }

  final baseContexts = List<AFBaseTestExecute>.of(contexts);
  printTestTotal(output, baseContexts, localStats);
  stats.mergeIn(localStats);
}
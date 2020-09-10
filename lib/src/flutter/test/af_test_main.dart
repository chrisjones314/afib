

import 'package:afib/afib_dart.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test_main.dart';
import 'package:afib/src/flutter/test/af_state_test_main.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/test/af_unit_test_main.dart';
import 'package:afib/src/flutter/utils/af_flutter_params.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:flutter_test/flutter_test.dart';

class AFibTestsFailedMatcher extends Matcher {
  AFibTestsFailedMatcher();

  @override
  Description describe(Description description) {
    return description.add("AFib state tests have no errors");
  }
  
  @override
  bool matches(desc, Map matchState) {
    return false;
  }
}

/// The main function which executes the store test defined in your initStateTests function.
Future<void> afTestMain(AFDartParams paramsD, AFFlutterParams paramsF, WidgetTester widgetTester) async {
  final paramsTest = paramsD.forceEnvironment(AFConfigEntryEnvironment.prototype);
  AFibD.initialize(paramsTest);
  AFibF.initialize(paramsF);

  // first unit tests
  final output = AFCommandOutput();
  final stats = AFTestStats();

  AFibD.logTest?.d("entering afUnitTestMain");
  afUnitTestMain(output, stats, paramsD, paramsF);
  AFibD.logTest?.d("exiting afUnitTestMain");

  // then state tests
  AFibD.logTest?.d("entering afStateTestMain");
  afStateTestMain(output, stats, paramsD, paramsF);
  AFibD.logTest?.d("exiting afStateTestMain");

  /// then screen tests
  AFibD.logTest?.d("entering afScreenTestMain");
  await afScreenTestMain(output, stats, paramsD, paramsF, widgetTester);
  AFibD.logTest?.d("exiting afScreenTestMain");

  if(stats.hasErrors) {
    expect("${stats.totalErrors} errors (see details above)", AFibTestsFailedMatcher());
  } else {
    output.writeSeparatorLine();
    AFBaseTestExecute.printTotalPass(output, "GRAND TOTAL", stats.totalPasses);
    output.writeSeparatorLine();   
  }
  return null;
}
// @dart=2.9
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/redux/state/af_app_state.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/af_app_ui_library.dart';
import 'package:afib/src/flutter/core/af_app_extension_context.dart';
import 'package:afib/src/flutter/test/af_base_test_execute.dart';
import 'package:afib/src/flutter/test/af_screen_test_main.dart';
import 'package:afib/src/flutter/test/af_state_test_main.dart';
import 'package:afib/src/flutter/test/af_test_stats.dart';
import 'package:afib/src/flutter/test/af_unit_test_main.dart';
import 'package:afib/src/flutter/ui/theme/af_default_fundamental_theme.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter_test/flutter_test.dart';

class AFibTestsFailedMatcher extends Matcher {
  AFibTestsFailedMatcher();

  @override
  Description describe(Description description) {
    return description.add("AFib state tests have no errors");
  }
  
  @override
  bool matches(dynamic desc, Map matchState) {
    return false;
  }
}

Future<void> afTestMainUILibrary<TState extends AFAppStateArea>(AFLibraryID id, AFExtendUILibraryDelegate extendApp, AFExtendThirdPartyDelegate extendThirdParty, AFExtendTestDelegate extendTest, AFDartParams paramsD, WidgetTester widgetTester) async {
  final contextLibrary = AFUILibraryExtensionContext(id: id);
  extendApp(contextLibrary);

  final extendAppFull = (context) {
    context.fromUILibrary(contextLibrary,
      createApp: () => AFAppUILibrary(),
      initFundamentalThemeArea: initAFDefaultFundamentalThemeArea,
    );
  };

  return afTestMain<TState>(extendAppFull, extendThirdParty, extendTest, paramsD, widgetTester);
}

/// The main function which executes the store test defined in your initStateTests function.
Future<void> afTestMain<TState extends AFAppStateArea>(AFExtendAppDelegate extendApp, AFExtendThirdPartyDelegate extendThirdParty, AFExtendTestDelegate extendTest, AFDartParams paramsD, WidgetTester widgetTester) async {
  final stopwatch = Stopwatch();
  stopwatch.start();

  final paramsTest = paramsD.forceEnvironment(AFEnvironment.prototype);
  AFibD.initialize(paramsTest);

  final context = AFAppExtensionContext();
  extendApp(context);
  extendTest(context.test);
  if(extendThirdParty != null) {
    extendThirdParty(context.thirdParty);
  }

  AFibF.initialize<TState>(context);

  // first unit tests
  final output = AFCommandOutput();
  final stats = AFTestStats();

  AFibD.logTest?.d("entering afUnitTestMain");
  afUnitTestMain<TState>(output, stats, paramsD);
  AFibD.logTest?.d("exiting afUnitTestMain");

  // then state tests
  AFibD.logTest?.d("entering afStateTestMain");
  afStateTestMain<TState>(output, stats, paramsD);
  AFibD.logTest?.d("exiting afStateTestMain");

  /// then screen tests
  AFibD.logTest?.d("entering afScreenTestMain");
  await afScreenTestMain<TState>(output, stats, paramsD, widgetTester);
  AFibD.logTest?.d("exiting afScreenTestMain");

  if(stats.hasErrors) {
    expect("${stats.totalErrors} errors (see details above)", AFibTestsFailedMatcher());
  } else if(AFConfigEntries.enabledTestList.isI18NEnabled(AFibD.config)) {
    final missing = AFibF.g.testMissingTranslations;
    if(missing.totalCount == 0) {
      AFBaseTestExecute.printTotalPass(output, "NO MISSING TRANSLATIONS", 0);
    } else {
      AFBaseTestExecute.printTotalFail(output, "MISSING TRANSLATIONS", missing.totalCount);
      for(final setT in missing.missing.values) {
        output.writeErrorLine("${setT.locale} missing: ");
        output.indent();
        for(final id in setT.translations.keys) {
          output.writeLine(id.toString());
        }
        output.outdent();

      }
    }

  } else {
    AFBaseTestExecute.writeSeparatorLine(output);
    AFBaseTestExecute.printTotalPass(output, "GRAND TOTAL", stats.totalPasses, stopwatch: stopwatch);
    if(stats.totalDisabled > 0) {
      AFBaseTestExecute.printTotalPass(output, "DISABLED", stats.totalDisabled, style: Styles.YELLOW, suffix: "disabled");
    }
    AFBaseTestExecute.writeSeparatorLine(output);
  }
  return null;
}
import 'package:afib/afib_uiid.dart';
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/af_command_output.dart';
import 'package:afib/src/dart/command/commands/af_typedefs_command.dart';
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
import 'package:flutter/material.dart';
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

Future<void> afTestMainUILibrary({
  required AFLibraryID id, 
  required AFExtendBaseDelegate installBase, 
  required AFExtendBaseDelegate installBaseLibrary, 
  required AFExtendCoreLibraryDelegate installCoreLibrary, 
  required AFExtendTestDelegate installTest, 
  required AFDartParams paramsDart, 
  required WidgetTester widgetTester
}) async {
  final appContext = AFAppExtensionContext();
  final contextLibrary = AFCoreLibraryExtensionContext(id: id, app: appContext.thirdParty);
  installCoreLibrary(contextLibrary);

  final extendAppFull = (context) {
    context.fromUILibrary(contextLibrary,
      createApp: () => const AFAppUILibrary(),
      defineAppFundamentalTheme: defineAFDefaultFundamentalTheme,
    );
  };

  return afTestMainApp(
    id: AFUILibraryID.id,
    installBase: installBase, 
    installBaseLibrary: installBaseLibrary, 
    installCoreApp: extendAppFull, 
    installTest: installTest, 
    paramsDart: paramsDart, 
    widgetTester: widgetTester,
    appContext: appContext,
  );
}

/// The main function which executes the store test defined in your initStateTests function.
Future<void> afTestMainApp({
  required AFLibraryID id,
  AFExtendBaseDelegate? installBase, 
  AFExtendBaseDelegate? installBaseLibrary, 
  required AFExtendAppDelegate installCoreApp, 
  AFExtendLibraryUIDelegate? installUILibrary, 
  required AFExtendTestDelegate installTest, 
  required AFDartParams paramsDart, 
  required WidgetTester widgetTester,
  AFAppExtensionContext? appContext,
}) async {
  final stopwatch = Stopwatch();
  stopwatch.start();

  final baseContext = AFBaseExtensionContext();
  if(installBase != null) {
    installBase(baseContext);
  }
  if(installBaseLibrary != null) {
    installBaseLibrary(baseContext);
  }

  final paramsTest = paramsDart.forceEnvironment(AFEnvironment.prototype);
  AFibD.initialize(paramsTest);

  final formFactor = AFibD.config.formFactorWithOrientation;
  final screenSize = Size(formFactor.width, formFactor.height);
  await widgetTester.binding.setSurfaceSize(screenSize);
  widgetTester.binding.window.physicalSizeTestValue = screenSize;
  widgetTester.binding.window.devicePixelRatioTestValue = 1.0;


  final context = appContext ?? AFAppExtensionContext();
  installCoreApp(context);
  installTest(context.test);
  if(installUILibrary != null) {
    installUILibrary(context.thirdParty);
  }
  AFibF.initialize(context, AFConceptualStore.appStore);

  // first unit tests
  final output = AFCommandOutput();
  final stats = AFTestStats();

  AFibD.logTestAF?.d("entering afUnitTestMain");
  afUnitTestMain(output, stats, paramsDart);
  AFibD.logTestAF?.d("exiting afUnitTestMain");

  // then state tests
  AFibD.logTestAF?.d("entering afStateTestMain");
  afStateTestMain(output, stats, paramsDart);
  AFibD.logTestAF?.d("exiting afStateTestMain");

  /// then screen tests
  AFibD.logTestAF?.d("entering afScreenTestMain");
  await afScreenTestMain(output, stats, paramsDart, widgetTester);
  AFibD.logTestAF?.d("exiting afScreenTestMain");

  if(stats.hasErrors) {
    if(stats.failedTests.isNotEmpty) {
      output.writeLine("The following tests failed: ");
      output.indent();
      for(final failed in stats.failedTests) {
        output.writeLine(failed.toString());
      }
      output.outdent();
    }
    expect("${stats.totalErrors} errors (see details above)", AFibTestsFailedMatcher());
  } else if(AFConfigEntries.testsEnabled.isI18NEnabled(AFibD.config)) {
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

  return;
}
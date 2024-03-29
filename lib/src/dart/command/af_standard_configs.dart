import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:args/args.dart';

class AFConfigEntryEnvironment extends AFConfigurationItemOptionChoice {
  static const specificItemConfigLocation = "(specified in initialization/environments/prototype.dart)";
  static const optionName = "environment";
  static const allEnvironments = AFEnvironment.values;
  
  AFConfigEntryEnvironment(): super(
    libraryId: AFUILibraryID.id,
    name: optionName, 
    defaultValue: AFEnvironment.production, 
    validContexts: AFConfigurationItem.validContextsAllButNew, 
    ordinal: 100.0,
  ) {

    addChoice(textValue: "debug", help: "For debugging", runtimeValue: AFEnvironment.debug);
    addChoice(textValue: "production", help: "For production", runtimeValue: AFEnvironment.production);
    addChoice(textValue: "prototype", help: "Interact with prototype screens, and run tests against them on the simulator", runtimeValue: AFEnvironment.prototype);
    addChoice(textValue: "startupInWireframe", help: "Startup in a wireframe specified by AFConfig.setStartupWireframe $specificItemConfigLocation", runtimeValue: AFEnvironment.startupInWireframe);
    addChoice(textValue: "workflowPrototype", help: "Startup in the terminal state of a state test, specified by AFConfig.setStartupStateTest $specificItemConfigLocation", runtimeValue: AFEnvironment.startupInStateTest);
    addChoice(textValue: "startupInScreenPrototype", help: "Startup in a specific screen prototype specified by AFConfig.setStartupScreenPrototype $specificItemConfigLocation", runtimeValue: AFEnvironment.startupInScreenPrototype);
    addChoice(textValue: "test", help: "Used internally when command-line tests are executing, not usually explicitly used by developers", runtimeValue: AFEnvironment.test);
  }

  @override
  void setValueWithString(AFConfig dest, String value) {
    final choice = this.findChoice(value);
    if(choice == null) {
      throw AFException("$value is not a valid option for $name");
    }
    dest.putInternal(this, choice.runtimeValue);
  }

  bool requiresPrototypeData(AFConfig config) {
    return config.isPrototypeEnvironment;
  }

  bool requiresTestData(AFConfig config) {
    final env = config.valueFor(this);
    return (env != AFEnvironment.production && env != AFEnvironment.debug);
  }

}


class AFConfigEntryLogArea extends AFConfigurationItemOptionChoice {
  static const query = "query";
  static const ui = "ui";
  static const test = "test";
  static const all = "all";
  static const afRoute = "af:route";
  static const afState = "af:state";
  static const afConfig = "af:config";
  static const afTheme = "af:theme";
  static const afQuery = "af:query";
  static const afUI = "af:ui";
  static const afTest = "af:test";
  static const commentOption = "//";
  static const standard = "standard";

  AFConfigEntryLogArea(): super(
    libraryId: AFUILibraryID.id,
    name: "logs-enabled", 
    defaultValue: [query, ui, test, commentOption, afRoute, afState], 
    validContexts: AFConfigurationItem.validContextsAllButNew, 
    ordinal: 200.0, 
    allowMultiple: true
  ) {
    addChoice(textValue: all, help: "Turn on all logging");
    addChoice(textValue: commentOption, help: "Disable all items after this in the logs-enabled array");

    addChoice(textValue: standard, help: "Logging for app/third-party query and ui, plus afib route and state");
    addChoice(textValue: ui, help: "App/third-party logging for any AFStateProgrammingInterface.log (e.g ...SPI.log) or AFBuildContext.log.");
    addChoice(textValue: query, help: "App/third-party logging on AFStartQueryContext.log, AFFinishQuerySuccessContext.log or AFFinishQueryErrorContext.log");
    addChoice(textValue: test, help: "App/third-party logging on test contexts: AFUIPrototypeDefinitionContext.log, AFStateTestDefinitionContext.log, AFDefineTestDataContext.log, AFDefineTestDataContext.log, AFWireframeDefinitionContext.log");    

    addChoice(textValue: afConfig, help: "Logging on any non-test definition/initialization context, and of afib.g.dart/startup configuration values");
    addChoice(textValue: afRoute, help: "Internal AFib logging related to routes and navigation");
    addChoice(textValue: afState, help: "Internal AFib logging related to app state");
    addChoice(textValue: afTheme, help: "Internal AFib logging related to theming");
    addChoice(textValue: afQuery, help: "Internal AFib logging for queries");
    addChoice(textValue: afTest, help: "Internal AFib logging for testing");
    addChoice(textValue: afUI, help: "Internal AFib logging for UI build");
  }

  List<String> areasFor(AFConfig config) {
    return config.stringListFor(this);
  }
}

class AFConfigEntryRecentTests extends AFConfigurationItem {
  AFConfigEntryRecentTests(): super(
    libraryId: AFUILibraryID.id,
    name: "tests-recent", 
    defaultValue: [], 
    validContexts: AFConfigurationItem.validContextsAllButNew, 
    ordinal: 200.0, 
    help: "list of recently run tests, maintained internally to support the recent feature on the prototype home screen"
  );

  @override
  void addArguments(ArgParser argParser) {
  }

  @override
  String? validate(dynamic value) {
    throw UnimplementedError();
  }

}

class AFConfigEntryEnabledTests extends AFConfigurationItemOptionChoice {
  static const allTests = "all";
  static const stateTests = "state";
  static const unitTests = "unit";
  static const screenTests = "screen";
  static const workflowTests = "workflow";
  static const dialogTests = "dialog";
  static const drawerTests = "drawer";
  static const bottomSheetTests = "bottomsheet";
  static const widgetTests = "widget";
  static const i18n = "i18n";
  static const allAreas = [allTests, unitTests, stateTests, widgetTests, dialogTests, bottomSheetTests, drawerTests, screenTests, workflowTests, i18n];

  AFConfigEntryEnabledTests(): super(
    libraryId: AFUILibraryID.id,
    name: "tests-enabled", 
    defaultValue: allTests, 
    validContexts: AFConfigurationItem.validContextsAllButNew, 
    ordinal: 400.0, 
    allowMultiple: true
  ) {
    addChoice(textValue: allTests, help: "All tests, not including i18n and regression");
    addChoice(textValue: stateTests, help: "State tests");
    addChoice(textValue: unitTests, help: "");    
    addChoice(textValue: widgetTests, help: "");    
    addChoice(textValue: dialogTests, help: "");    
    addChoice(textValue: bottomSheetTests, help: "");
    addChoice(textValue: screenTests, help: "");    
    addChoice(textValue: drawerTests, help: "");
    addChoice(textValue: workflowTests, help: "");    
    addChoice(textValue: i18n, help: "");    
    addWildcard("Or, the full identifier of any prototype, test name, or tag");
  }

  bool isAreaEnabled(AFConfig config, String areaTest) {
    final areas = _params(config);
    if(hasNoAreas(areas)) {
      return true;
    }
    for(final area in areas) {
      if(area == allTests) {
        return true;
      }
      final actualArea = _extractArea(area);
      if(areaTest == actualArea) {
        return true;
      }
    }
    return false;
  }

  bool isI18NEnabled(AFConfig config) {
    final areas = config.stringListFor(this);
    return areas.contains(i18n);
  }

  bool isTestEnabled(AFConfig config, AFBaseTestID id) {
    final areas = _params(config);
    if(hasOnlyAreas(areas)) {
      return true;
    }
    if(areas.contains(id.code)) {
      return true;
    }
    return false;
  }

  List<String> _params(AFConfig config) {
    var result = config.stringListFor(this);
    if(result.contains(i18n)) {
      result = List<String>.from(result);
      result.remove(i18n);
    }
    return result;
  }

  bool hasNoAreas(List<String> areas) {
    for(final area in areas) {
      final actualArea = _extractArea(area);
      if(allAreas.contains(actualArea)) {
        return false;
      }
    }
    return true;
  }

  bool hasOnlyAreas(List<String> areas) {
    for(final area in areas) {
      if(!allAreas.contains(area)) {
        return false;
      }
    }
    return true;
  }

  String _extractArea(String area) {
    final idx = area.indexOf(":");
    if(idx < 0) {
      return area;
    }
    return area.substring(0, idx);
  }

}


class AFConfigEntryTestSize extends AFConfigurationItemOptionChoice {

  AFConfigEntryTestSize(): super(
    libraryId: AFUILibraryID.id,
    name: "test-size", 
    help: "The size used for command line tests, often used in conjunction with test-orientation",
    defaultValue: AFFormFactorSize.idPhoneStandard, 
    validContexts: AFConfigurationItem.validContextsAll, 
    ordinal: 450.0, 
    allowMultiple: false
  ) {
    for(final size in AFibD.standardSizes.values) {
      addChoice(textValue: size.identifier, help: size.dimensionsText, runtimeValue: size);
    }
    addWildcard("Or, [width]x[height], e.g. 1000x2000");
  }

  /// Return an error message if the value is invalid, otherwise return null.
  @override
  String? validate(dynamic value) {
    final parsed = _parseValue(value);
    if(parsed is String) {
      return parsed;
    }
    return null;
  }

  dynamic _parseValue(String value) {
    final standard = AFibD.findSize(value);
    if(standard != null) {
      return standard;
    }

    const badFormatError = "Expected test-size to be either a standard size (see afib.dart help config) or [width]x[height]";
    final dims = value.split("x");
    if(dims.length != 2) {
      return badFormatError;
    }
    final sw = dims[0];
    final sh = dims[1];
    final w = double.tryParse(sw);
    final h = double.tryParse(sh);
    if(w == null || h == null) {
      return badFormatError;
    }

    return AFFormFactorSize(identifier: "custom${w}x$h", width: w, height: h);
  }

  @override
  void setValue(AFConfig dest, dynamic value) {
    if(value is String) {
      final size = _parseValue(value);
      dest.putInternal(this, size);
    } else {
      dest.putInternal(this, value);
    }
  }

  @override
  String codeValue(AFConfig config) {
    dynamic val = config.valueFor(this);
    if(val is String && !val.contains("custom")) {
      return '"$val"';
    } 
    if(!val.identifier.contains("custom")) {
      return '"${val.identifier}"';
    }     
    return '"${val.width}x${val.height}"';
  }


}

class AFConfigEntryTestOrientation extends AFConfigurationItemOptionChoice {

  AFConfigEntryTestOrientation(): super(
    libraryId: AFUILibraryID.id,
    name: "test-orientation", 
    help: "The orientation used in command line tests",
    defaultValue: AFFormFactorSize.idOrientationPortrait, 
    validContexts: AFConfigurationItem.validContextsAll, 
    ordinal: 470.0, 
    allowMultiple: false
  ) {
    addChoice(textValue: AFFormFactorSize.idOrientationPortrait, help: "Portrait, height larger than width");
    addChoice(textValue: AFFormFactorSize.idOrientationLandscape, help: "Landscape, width larger than height");
  }

  /// Return an error message if the value is invalid, otherwise return null.
  @override
  String? validate(dynamic value) {
    if(value != AFFormFactorSize.idOrientationPortrait && value != AFFormFactorSize.idOrientationLandscape) {
      return "Value for $name must be ${AFFormFactorSize.idOrientationPortrait} or ${AFFormFactorSize.idOrientationLandscape}";
    }
    return null;
  }
}


import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';

class AFConfigEntryEnvironment extends AFConfigEntryOptionChoice {
  static const optionName = "environment";
  static const allEnvironments = AFEnvironment.values;
  
  AFConfigEntryEnvironment(): super(
    name: optionName, 
    defaultValue: AFEnvironment.production, 
    validContexts: AFConfigItem.validContextsAllButNew, 
    ordinal: 100.0,
  ) {
    addChoice(textValue: "debug", help: "For debugging", runtimeValue: AFEnvironment.debug);
    addChoice(textValue: "production", help: "For production", runtimeValue: AFEnvironment.production);
    addChoice(textValue: "prototype", help: "Interact with prototype screens, and run tests against them on the simulator", runtimeValue: AFEnvironment.prototype);
    addChoice(textValue: "test", help: "Used internally when command-line tests are executing, not usually explicitly used by developers", runtimeValue: AFEnvironment.test);
  }

  void setValueWithString(AFConfig dest, String value) {
    final choice = this.findChoice(value);
    if(choice == null) {
      throw AFException("$value is not a valid option for $name");
    }
    dest.putInternal(this, choice.runtimeValue);
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


class AFConfigEntryLogArea extends AFConfigEntryOptionChoice {
  static const query = "query";
  static const config = "config";
  static const test = "test";
  static const route = "route";
  static const state = "state";
  static const theme = "theme";
  static const none = "none";
  static const all = "all";
  static const app = "app";
  static const ui = "ui";

  AFConfigEntryLogArea(): super(
    name: "logs-enabled", 
    defaultValue: app, 
    validContexts: AFConfigItem.validContextsAllButNew, 
    ordinal: 200.0, 
    allowMultiple: true
  ) {
    addChoice(textValue: none, help: "Turn off all logging");
    addChoice(textValue: app, help: "Show log messages from app-specific code for query, route, state and ui");
    addChoice(textValue: ui, help: "Show log messages on any AFBuildContext");
    addChoice(textValue: query, help: "Logging on AFStartQueryContext, AFFinishQuerySuccessContext or AFFinishQueryErrorContext");
    addChoice(textValue: config, help: "Logging on any non-test definition/initialization context, and of afib.g.dart/startup configuration values");
    addChoice(textValue: test, help: "Logging on test definition contexts and all test execution contexts");
    addChoice(textValue: route, help: "Logging of any action that modified a route");
    addChoice(textValue: state, help: "Logging of any action that modifies an app state");
    addChoice(textValue: theme, help: "Logging of changes related to theming");
  }

  List<String> areasFor(AFConfig config) {
    return config.stringListFor(this);
  }
}

class AFConfigEntryEnabledTests extends AFConfigEntryOptionChoice {
  static const allTests = "all";
  static const stateTests = "state";
  static const unitTests = "unit";
  static const screenTests = "screen";
  static const workflowTests = "workflow";
  static const widgetTests = "widget";
  static const i18n = "i18n";
  static const allAreas = [allTests, unitTests, stateTests, widgetTests, screenTests, workflowTests, i18n];

  AFConfigEntryEnabledTests(): super(
    name: "tests-enabled", 
    defaultValue: allTests, 
    validContexts: AFConfigItem.validContextsAllButNew, 
    ordinal: 300.0, 
    allowMultiple: true
  ) {
    addChoice(textValue: allTests, help: "All tests, not including i18n and regression");
    addChoice(textValue: stateTests, help: "State tests");
    addChoice(textValue: unitTests, help: "");    
    addChoice(textValue: widgetTests, help: "");    
    addChoice(textValue: screenTests, help: "");    
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
    for(final area in areas) {
      final actualTag = _extractTag(area);
      if(id.hasTag(actualTag)) {
        return true;
      }
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

  String _extractTag(String area) {
    final idx = area.indexOf(":");
    if(idx < 0) {
      return area;
    }
    return area.substring(idx+1);
  }
}


class AFConfigEntryTestSize extends AFConfigEntryOptionChoice {

  AFConfigEntryTestSize(): super(
    name: "test-size", 
    help: "The size used for command line tests, often used in conjunction with test-orientation",
    defaultValue: AFFormFactorSize.idPhoneStandard, 
    validContexts: AFConfigItem.validContextsAll, 
    ordinal: 350.0, 
    allowMultiple: false
  ) {
    for(final size in AFibD.standardSizes.values) {
      addChoice(textValue: size.identifier, help: size.dimensionsText, runtimeValue: size);
    }
    addWildcard("Or, [width]x[height], e.g. 1000x2000");
  }

  /// Return an error message if the value is invalid, otherwise return null.
  String validate(dynamic value) {
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

    const badFormatError = "Expected test-size to be either a standard size (see afib.dart help config) or [width]x[height]";;
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
    if(!val.identifier.contains("custom")) {
      return '"${val.identifier}"';
    } 
    return '"${val.width}x${val.height}"';
  }


}

class AFConfigEntryTestOrientation extends AFConfigEntryOptionChoice {

  AFConfigEntryTestOrientation(): super(
    name: "test-orientation", 
    help: "The orientation used in command line tests",
    defaultValue: AFFormFactorSize.idPhoneStandard, 
    validContexts: AFConfigItem.validContextsAll, 
    ordinal: 370.0, 
    allowMultiple: false
  ) {
    addChoice(textValue: AFFormFactorSize.idOrientationPortrait, help: "Portrait, height larger than width");
    addChoice(textValue: AFFormFactorSize.idOrientationLandscape, help: "Landscape, width larger than height");
  }

  /// Return an error message if the value is invalid, otherwise return null.
  String validate(dynamic value) {
    if(value != AFFormFactorSize.idOrientationPortrait && value != AFFormFactorSize.idOrientationLandscape) {
      return "Value for $name must be ${AFFormFactorSize.idOrientationPortrait} or ${AFFormFactorSize.idOrientationLandscape}";
    }
    return null;
  }
}

import 'package:afib/id.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_startup_screen.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/material.dart';

/// A mapping of screen identifiers to screen.  This mapping is used to 
/// build the correct screen widget for the leaf element in the route.
class AFScreenMap {

  AFCreateRouteParamDelegate? _createStartupScreenParam;
  AFCreateRouteParamDelegate? trueCreateStartupScreenParam;
  AFScreenID? _startupScreenId;
  final Map<AFScreenID, AFConnectedUIBuilderDelegate> _screens = <AFScreenID, AFConnectedUIBuilderDelegate>{};
  final Map<AFWidgetID, AFConnectedUIBuilderDelegate> _widgets = <AFWidgetID, AFConnectedUIBuilderDelegate>{};

  AFScreenMap();

  AFScreenID? get startupScreenId {
    if(_startupScreenId == AFUIScreenID.screenPrototypeHome) {
      return _startupScreenId;
    }
    return _startupScreenId;
  }

  String get appInitialScreenId { 
    final startupId = _startupScreenId;
    if(startupId == null) throw AFException("Missing startup screen id");
    return startupId.code;
  }

  Map<String, WidgetBuilder> get screens {
     final result = _screens.map<String, WidgetBuilder>((k, v) {
       return MapEntry(k.code, v);
     });
     result[AFUIScreenID.screenStartupWrapper.code] = (_) => AFStartupScreenWrapper();
     return result;
  }

  WidgetBuilder? findBy(AFScreenID id) {
    return _screens[id];
  }

  AFConnectedUIBase createInstance(AFScreenID id, BuildContext? buildContext) {
    final builder = _screens[id];
    if(builder == null) {
      throw AFException("Please add an entry for $id in screen_map.dart");
    }
    return builder(buildContext);
  }

  Widget createFor(AFScreenID id, BuildContext context) {
    final builder = _screens[id];
    if(builder == null) {
      if(id == AFUIScreenID.screenStartupWrapper) {
        return AFStartupScreenWrapper();
      }
      throw AFException("Please add an entry for $id in screen_map.dart");
    }
    return builder(context);
  }

  AFCreateRouteParamDelegate? get startupRouteParamFactory {
    return _createStartupScreenParam;
}

  /// Call [startupScreen] once to specify the initial screen for your app.
  void startupScreen(AFScreenID screenId, AFCreateRouteParamDelegate createParam) {    
    if(_startupScreenId == null) {
      trueCreateStartupScreenParam = createParam;
    }
    _startupScreenId = screenId;
    _createStartupScreenParam = createParam;
  }
  /// Call [screen] multiple times to specify the relationship between 
  /// [screenKey] and screens built by the [WidgetBuilder]
  void screen(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    _screens[screenKey] = screenBuilder;
  }

  /// Returns the widget builder for the initial screen.
  WidgetBuilder? get initialScreenBuilder {
    final environment = AFibD.config.environment;
    if(environment == AFEnvironment.prototype) {
      return _screens[AFUIScreenID.screenPrototypeHome];
    } else if(environment == AFEnvironment.wireframe ||
              environment == AFEnvironment.screenPrototype ||
              environment == AFEnvironment.workflowPrototype) {
      return _screens[AFUIScreenID.screenPrototypeLoading];
    }

    return _screens[_startupScreenId];
  }

  /// Returns the current mapping of routes to screens.
  Map<AFID, WidgetBuilder> get screenMap {
    return _screens;
  }

  void widget(AFWidgetID widget, AFConnectedUIBuilderDelegate widgetBuilder) {
    _widgets[widget] = widgetBuilder;
  }
}

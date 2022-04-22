import 'package:afib/afui_id.dart';
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/ui/screen/af_startup_screen.dart';
import 'package:afib/src/flutter/ui/screen/afui_unimplemented_screen.dart';
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
     result[AFUIScreenID.screenUnimplemented.code] = (_) => AFUIUnimplementedScreen();
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

  /// Call [registerStartupScreen] once to specify the initial screen for your app.
  void registerStartupScreen(AFScreenID screenId, AFCreateRouteParamDelegate createParam) {    
    if(_startupScreenId == null) {
      trueCreateStartupScreenParam = createParam;
    }
    _startupScreenId = screenId;
    _createStartupScreenParam = createParam;
  }
  /// Call [registerScreen] multiple times to specify the relationship between 
  /// [screenKey] and screens built by the [WidgetBuilder]
  void registerScreen(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    assert(_isValidBuilder<AFConnectedScreen>(screenBuilder));
    _screens[screenKey] = screenBuilder;
  }

  void registerDrawer(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    assert(_isValidDrawerBuilder(screenBuilder));
    _screens[screenKey] = screenBuilder;
  }

  void registerDialog(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    assert(_isValidBuilder<AFConnectedDialog>(screenBuilder));
    _screens[screenKey] = screenBuilder;
  }

  void registerBottomSheet(AFScreenID screenKey, AFConnectedUIBuilderDelegate screenBuilder) {
    assert(_isValidBuilder<AFConnectedBottomSheet>(screenBuilder));
    _screens[screenKey] = screenBuilder;
  }

  bool _isValidBuilder<TScreen extends AFConnectedUIBase>(AFConnectedUIBuilderDelegate screenBuilder) {
    final screen = screenBuilder(null);
    assert(screen is TScreen);
    return true;
  }

  bool _isValidDrawerBuilder(AFConnectedUIBuilderDelegate screenBuilder) {
    final screen = screenBuilder(null);
    assert(screen is AFConnectedDrawer);
    assert(screen.launchParam != null, "You must specify a launch parameter for a drawer, since it can be dragged onto the screen spontaneously.");
    return true;
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

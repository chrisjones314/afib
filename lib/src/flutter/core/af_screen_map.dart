import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:afib/src/flutter/screen/af_startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_dart.dart';

/// A mapping of screen identifiers to screen.  This mapping is used to 
/// build the correct screen widget for the leaf element in the route.
class AFScreenMap {

  AFScreenID _startupScreenId;
  AFRouteParam _startupScreenParam;
  final Map<AFScreenID, WidgetBuilder> _screens = <AFScreenID, WidgetBuilder>{};

  AFScreenMap() {
    screen(AFUIID.screenStartupWrapper, (_) => AFStartupScreenWrapper());
  }

  AFScreenID get startupScreenId {
    if(_startupScreenId == AFUIID.screenPrototypeHome) {
      return _startupScreenId;
    }
    return _startupScreenId;
  }

  String get appInitialScreenId { 
    return _startupScreenId.code;
  }

  Map<String, WidgetBuilder> get screens {
     return _screens.map<String, WidgetBuilder>((k, v) {
       return MapEntry(k.code, v);
     });
  }

  WidgetBuilder findBy(AFScreenID id) {
    return _screens[id];
  }

  Widget createFor(AFScreenID id) {
    return _screens[id](null);
  }

  AFRouteParam get startupRouteParam {
    return _startupScreenParam;
  }

  /// Call [startupScreen] once to specify the initial screen for your app.
  void startupScreen(AFScreenID screenId, WidgetBuilder screenBuilder, AFRouteParam initialParam) {
    AFibF.verifyNotImmutable();
    
    _startupScreenId = screenId;
    _startupScreenParam = initialParam;
    screen(screenId, screenBuilder);
  }

  /// Call [screen] multiple times to specify the relationship between 
  /// [screenKey] and screens built by the [WidgetBuilder]
  void screen(AFScreenID screenKey, WidgetBuilder screenBuilder) {
    AFibF.verifyNotImmutable();
    _screens[screenKey] = screenBuilder;
  }

  /// Returns the widget builder for the initial screen.
  WidgetBuilder get initialScreenBuilder {
    return _screens[_startupScreenId];
  }

  /// Returns the current mapping of routes to screens.
  Map<AFID, WidgetBuilder> get screenMap {
    return _screens;
  }
}

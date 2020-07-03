import 'package:afib/src/dart/utils/af_ui_id.dart';
import 'package:afib/src/flutter/utils/afib_f.dart';
import 'package:afib/src/flutter/screen/af_startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_dart.dart';

/// A mapping of screen identifiers to screen.  This mapping is used to 
/// build the correct screen widget for the leaf element in the route.
class AFScreenMap {

  AFScreenID _initialKey;
  final Map<AFScreenID, WidgetBuilder> _screens = Map<AFScreenID, WidgetBuilder>();

  AFScreenMap() {
    screen(AFUIID.screenStartup, (_) => AFStartupScreenWrapper());
  }

  AFScreenID get afStartupScreenId {
    return AFUIID.screenStartup;
  }

  String get appInitialScreenId { 
    return _initialKey.code;
  }

  Map<String, WidgetBuilder> get screens {
     return _screens.map<String, WidgetBuilder>((k, v) {
       return MapEntry(k.code, v);
     });
  }

  /// Call [initialScreen] once to specify the initial screen for your app.
  void initialScreen(AFScreenID screenKey, WidgetBuilder screenBuilder) {
    AFibF.verifyNotImmutable();
    
    if(_initialKey != null) {
      throw AFException("Specified initial screen twice.");
    }
    _initialKey = screenKey;
    screen(screenKey, screenBuilder);
  }

  /// Call [screen] multiple times to specify the relationship between 
  /// [screenKey] and screens built by the [WidgetBuilder]
  void screen(AFScreenID screenKey, WidgetBuilder screenBuilder) {
    AFibF.verifyNotImmutable();
    _screens[screenKey] = screenBuilder;
  }

  /// Returns the widget builder for the initial screen.
  WidgetBuilder get initialScreenBuilder {
    return _screens[_initialKey];
  }

  /// Returns the current mapping of routes to screens.
  Map<AFID, WidgetBuilder> get screenMap {
    return _screens;
  }
}

import 'package:afib/src/flutter/af.dart';
import 'package:afib/src/flutter/screen/af_startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_dart.dart';

/// A mapping of screen identifiers to screen.  This mapping is used to 
/// build the correct screen widget for the leaf element in the route.
class AFScreenMap {

  String _initialKey;
  final Map<String, WidgetBuilder> _screens = Map<String, WidgetBuilder>();

  AFScreenMap() {
    screen(AFConfigConstants.startupScreenId, (_) => AFStartupScreenWrapper());
  }

  String get initialScreenId { 
    return _initialKey;
  }

  Map<String, WidgetBuilder> get screens {
     return _screens;
  }

  /// Call [initialScreen] once to specify the initial screen for your app.
  void initialScreen(String screenKey, WidgetBuilder screenBuilder) {
    AF.verifyNotImmutable();
    
    if(_initialKey != null) {
      throw AFException("Specified initial screen twice.");
    }
    _initialKey = screenKey;
    screen(screenKey, screenBuilder);
  }

  /// Call [screen] multiple times to specify the relationship between 
  /// [screenKey] and screens built by the [WidgetBuilder]
  void screen(String screenKey, WidgetBuilder screenBuilder) {
    AF.verifyNotImmutable();
    _screens[screenKey] = screenBuilder;
  }

  /// Returns the widget builder for the initial screen.
  WidgetBuilder get initialScreenBuilder {
    return _screens[_initialKey];
  }

  /// Returns the current mapping of routes to screens.
  Map<String, WidgetBuilder> get screenMap {
    return _screens;
  }
}

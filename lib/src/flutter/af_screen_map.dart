import 'package:afib/src/flutter/af.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_dart.dart';

/// A mapping of screen identifiers to screen.  This mapping is used to 
/// build the correct screen widget for the leaf element in the route.
class AFScreenMap {

  String initialKey;
  final Map<String, WidgetBuilder> screens = Map<String, WidgetBuilder>();

  /// Call [initialScreen] once to specify the initial screen for your app.
  void initialScreen(String screenKey, WidgetBuilder screenBuilder) {
    AF.verifyNotImmutable();
    
    if(initialKey != null) {
      throw AFException("Specified initial screen twice.");
    }
    initialKey = screenKey;
    screen(screenKey, screenBuilder);
  }

  /// Call [screen] multiple times to specify the relationship between 
  /// [screenKey] and screens built by the [WidgetBuilder]
  void screen(String screenKey, WidgetBuilder screenBuilder) {
    AF.verifyNotImmutable();
    screens[screenKey] = screenBuilder;
  }

  /// Returns the current mapping of routes to screens.
  Map<String, WidgetBuilder> screenMap() {
    return screens;
  }
}

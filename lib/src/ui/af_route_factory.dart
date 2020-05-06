import 'package:flutter/material.dart';

/// Each AFib application has one route map, which it populates by overriding 
/// the [configure] method.  
abstract class AFRouteMap {

  String initialRoute;
  Map<String, WidgetBuilder> routes = Map<String, WidgetBuilder>();

  /// Call [initial] once to specify the initial screen for your app.
  void initial(String routeKey, WidgetBuilder screenBuilder) {

  }

  /// Call [screen] multiple times to specify the relationship between 
  /// [routeKey] and screens built by the [WidgetBuilder]
  void screen(String routeKey, WidgetBuilder screenBuilder) {
    routes[routeKey] = screenBuilder;
  }

  /// Returns the current mapping of routes to screens.
  Map<String, WidgetBuilder> routeMap() {
    return routes;
  }

  /// Override [configure] to setup the route map for your application at 
  /// application startup.
  void configure3();

}

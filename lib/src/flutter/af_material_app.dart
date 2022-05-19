import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:overlay_support/overlay_support.dart';


class AFNavigatorObserver extends NavigatorObserver {
  void didPop(Route route, Route? previousRoute) {
    _logNav("didPPop");
  }

  void didPush(Route route, Route? previousRoute) {
    _logNav("didPush");
  }

  void didRemove(Route route, Route? previousRoute) {
    _logNav("didRemove");

  }
  
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _logNav("didReplace");
  }

  void didStartUserGesture(Route route, Route? previousRoute) {
    _logNav("didStartUserGesture");
  }

  void didStopUserGesture() {
    _logNav("didStopUserGesture");
  }

  void _logNav(String title) {
    //AFibD.logRoute?.d("$title");
  }

}

/// The parent class of [MaterialApp] based AFib apps.
/// 
/// The framework creates a subclass of this app for you,
/// and configures it in the main function of your app.
abstract class AFMaterialApp<AppState> extends AFApp<AppState> {
  
  /// Construct an app with the specified [AFScreenMap]
  AFMaterialApp(): super();
  
  /// This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    final store = AFibF.g.internalOnlyActiveStore;
    return StoreProvider(
      store: store,      
      child: OverlaySupport(
        child: _buildMaterialApp(context)
      )
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return StoreConnector<AFState, AFFundamentalThemeState>(
        converter: (store) {
          return store.state.public.themes.fundamentals;
        },
        distinct: true,
        builder: (buildContext, fundamentals) {
          return buildMaterialApp(fundamentals);
        }
    );
  }

  /// Build a [MaterialApp] for the application
  Widget buildMaterialApp(AFFundamentalThemeState fundamentals);

  AFNavigatorObserver createAFNavigatorObserver() {
    return AFNavigatorObserver();
  }
}

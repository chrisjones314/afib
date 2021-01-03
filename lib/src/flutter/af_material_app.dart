import 'package:afib/afib_dart.dart';
import 'package:afib/src/flutter/af_app.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:overlay_support/overlay_support.dart';


class AFNavigatorObserver extends NavigatorObserver {
  void didPop(Route route, Route previousRoute) {
    // with the notion of global route parameters for 
    // things like drawers, I don't think this is necessary.
    //if(!AFibF.g.withinMiddewareNavigation) {
    // AFibF.g.correctForFlutterPopNavigation();
    //}    
  }

  void didPush(Route route, Route previousRoute) {
    _logNav("didPush");
  }

  void didRemove(Route route, Route previousRoute) {
    _logNav("didRemove");

  }
  
  void didReplace({Route newRoute, Route oldRoute}) {
    _logNav("didReplace");
  }

  void didStartUserGesture(Route route, Route previousRoute) {
    _logNav("didStartUserGesture");
  }

  void didStopUserGesture() {
    _logNav("didStopUserGesture");
  }

  void _logNav(String title) {
    AFibD.logRoute?.d("$title");
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
    return StoreProvider(
      store: AFibF.g.storeInternalOnly,      
      child: OverlaySupport(
        child: _buildMaterialApp(context)
      )
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return StoreConnector<AFState, AFFundamentalTheme>(
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
  Widget buildMaterialApp(AFFundamentalTheme themeData);

  AFNavigatorObserver createAFNavigatorObserver() {
    return AFNavigatorObserver();
  }
}

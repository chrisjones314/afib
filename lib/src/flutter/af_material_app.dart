import 'package:afib/src/flutter/af_app.dart';
import 'package:flutter/material.dart';
import 'package:afib/afib_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';

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
      store: AF.store,
      child: buildMaterialApp()
    );
  }

  /// Build a [MaterialApp] for the application
  Widget buildMaterialApp();
}

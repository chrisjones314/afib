import 'package:afib/afib_flutter.dart';
import 'package:flutter/material.dart';


/// The parent class of [MaterialApp] based AFib apps.
/// 
/// The framework creates a subclass of this app for you,
/// and configures it in the main function of your app.
abstract class AFApp<AppState> extends StatelessWidget {
  /// Construct an app with the specified [AFScreenMap]
  const AFApp({
    super.key,
  });

  ///
  void afBeforeRunApp() {
    beforeRunApp();
  }

  void afAfterRunApp() {
    afterRunApp();
  }

  /// Called before the main flutter runApp loop.  
  /// 
  /// Do setup here.
  void beforeRunApp() {
  }

  /// Called after the main runApp loop.  
  /// 
  /// Do cleanup here.
  void afterRunApp() {

  }

}